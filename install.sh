#!/usr/bin/env bash
set -euo pipefail

pack="collaboration"
target="."
mode="link"
all=0
force=0
dry_run=0
kind_filter=""
name_filter=""

append_csv() {
  local current="$1"
  local value="$2"
  if [ -z "$current" ]; then
    printf '%s' "$value"
  else
    printf '%s,%s' "$current" "$value"
  fi
}

usage() {
  cat <<'USAGE'
Usage: install.sh [options]

Options:
  --pack <name>       Pack to install (default: collaboration)
  --target <path>     Target repository root (default: current directory)
  --all               Install every item in the pack
  --kind <kind>       Install default items of this kind: agent, skill, command, plugin
  --name <name>       Install item by name
  --agent <name>      Install an agent by name
  --skill <name>      Install a skill by name
  --command <name>    Install a command by name
  --plugin <name>     Install a plugin by name
  --link              Create symlinks (default)
  --copy              Copy files/directories instead of linking
  --force             Replace existing harness symlinks that point elsewhere
  --dry-run           Print actions without changing files
  -h, --help          Show this help
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --pack) pack="$2"; shift 2 ;;
    --target) target="$2"; shift 2 ;;
    --all) all=1; shift ;;
    --kind) kind_filter="$(append_csv "$kind_filter" "$2")"; shift 2 ;;
    --name) name_filter="$(append_csv "$name_filter" "$2")"; shift 2 ;;
    --agent) kind_filter="$(append_csv "$kind_filter" "agent")"; name_filter="$(append_csv "$name_filter" "$2")"; shift 2 ;;
    --skill) kind_filter="$(append_csv "$kind_filter" "skill")"; name_filter="$(append_csv "$name_filter" "$2")"; shift 2 ;;
    --command) kind_filter="$(append_csv "$kind_filter" "command")"; name_filter="$(append_csv "$name_filter" "$2")"; shift 2 ;;
    --plugin) kind_filter="$(append_csv "$kind_filter" "plugin")"; name_filter="$(append_csv "$name_filter" "$2")"; shift 2 ;;
    --link) mode="link"; shift ;;
    --copy) mode="copy"; shift ;;
    --force) force=1; shift ;;
    --dry-run) dry_run=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 2 ;;
  esac
done

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

contains_csv() {
  local csv="$1"
  local needle="$2"
  local item
  IFS=',' read -ra parts <<< "$csv"
  for item in "${parts[@]}"; do
    if [ "$item" = "$needle" ]; then
      return 0
    fi
  done
  return 1
}

is_selected() {
  local item_kind="$1"
  local item_name="$2"
  local item_default="$3"

  if [ "$all" -eq 1 ]; then
    return 0
  fi

  if [ -n "$name_filter" ]; then
    contains_csv "$name_filter" "$item_name" || return 1
    if [ -n "$kind_filter" ]; then
      contains_csv "$kind_filter" "$item_kind" || return 1
    fi
    return 0
  fi

  if [ -n "$kind_filter" ]; then
    contains_csv "$kind_filter" "$item_kind" || return 1
    [ "$item_default" = "true" ] && return 0 || return 1
  fi

  [ "$item_default" = "true" ]
}

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
pack_root="$script_dir/packs/$pack"
manifest="$pack_root/pack.toml"
target_root="$(cd "$target" && pwd)"

if [ ! -f "$manifest" ]; then
  echo "Pack manifest not found: $manifest" >&2
  exit 1
fi

install_item() {
  local item_kind="$1"
  local item_name="$2"
  local item_source="$3"
  local item_target="$4"
  local item_default="$5"

  [ -n "$item_name" ] || return 0
  is_selected "$item_kind" "$item_name" "$item_default" || return 0

  local src="$pack_root/$item_source"
  local dest="$target_root/$item_target"
  local parent
  parent="$(dirname "$dest")"

  if [ ! -e "$src" ]; then
    echo "Source not found for $item_kind '$item_name': $src" >&2
    exit 1
  fi

  if [ "$dry_run" -eq 1 ]; then
    echo "Would $mode $item_kind '$item_name': $dest -> $src"
    return 0
  fi

  mkdir -p "$parent"

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ -L "$dest" ]; then
      local current
      current="$(readlink "$dest")"
      if [ "$current" = "$src" ]; then
        echo "Already installed: $item_kind '$item_name'"
        return 0
      fi
      if [ "$force" -eq 1 ]; then
        rm "$dest"
      else
        echo "Refusing to replace existing symlink: $dest" >&2
        exit 1
      fi
    else
      if [ "$force" -eq 1 ]; then
        rm -rf "$dest"
      else
        echo "Refusing to overwrite non-link path: $dest" >&2
        exit 1
      fi
    fi
  fi

  if [ "$mode" = "copy" ]; then
    cp -R "$src" "$dest"
    echo "Copied $item_kind '$item_name' to $dest"
  else
    ln -s "$src" "$dest"
    echo "Linked $item_kind '$item_name' to $dest"
  fi
}

item_kind=""
item_name=""
item_source=""
item_target=""
item_default="false"
in_item=0

flush_item() {
  install_item "$item_kind" "$item_name" "$item_source" "$item_target" "$item_default"
  item_kind=""
  item_name=""
  item_source=""
  item_target=""
  item_default="false"
}

while IFS= read -r raw_line || [ -n "$raw_line" ]; do
  line="${raw_line%%#*}"
  line="$(trim "$line")"
  [ -n "$line" ] || continue

  if [ "$line" = "[[item]]" ]; then
    flush_item
    in_item=1
    continue
  fi

  if [ "$in_item" -eq 1 ] && [[ "$line" == *=* ]]; then
    key="$(trim "${line%%=*}")"
    value="$(trim "${line#*=}")"
    value="${value%\"}"
    value="${value#\"}"
    case "$key" in
      kind) item_kind="$value" ;;
      name) item_name="$value" ;;
      source) item_source="$value" ;;
      target) item_target="$value" ;;
      default) item_default="$value" ;;
    esac
  fi
done < "$manifest"

flush_item
