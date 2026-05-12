[CmdletBinding()]
param(
    [string]$Pack = "collaboration",
    [string]$Target = ".",
    [ValidateSet("link", "copy")]
    [string]$Mode = "link",
    [string[]]$Kind = @(),
    [string[]]$Name = @(),
    [switch]$All,
    [switch]$Force,
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-FullPath {
    param([string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }

    return [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $Path))
}

function Convert-ManifestValue {
    param([string]$Value)

    $trimmed = $Value.Trim()
    if ($trimmed -eq "true") { return $true }
    if ($trimmed -eq "false") { return $false }
    if ($trimmed.StartsWith('"') -and $trimmed.EndsWith('"')) {
        return $trimmed.Substring(1, $trimmed.Length - 2)
    }
    return $trimmed
}

function Read-PackItems {
    param([string]$ManifestPath)

    $items = @()
    $current = $null

    foreach ($line in Get-Content -LiteralPath $ManifestPath) {
        $trimmed = ($line -replace '\s+#.*$', '').Trim()
        if (-not $trimmed) { continue }

        if ($trimmed -eq '[[item]]') {
            if ($null -ne $current) {
                $items += [pscustomobject]$current
            }
            $current = @{}
            continue
        }

        if ($null -ne $current -and $trimmed -match '^([A-Za-z0-9_-]+)\s*=\s*(.+)$') {
            $current[$Matches[1]] = Convert-ManifestValue $Matches[2]
        }
    }

    if ($null -ne $current) {
        $items += [pscustomobject]$current
    }

    return $items
}

$kindFilter = @($Kind | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$nameFilter = @($Name | ForEach-Object { $_ -split ',' } | Where-Object { $_ })

function Test-Selected {
    param([pscustomobject]$Item)

    $isDefault = $false
    if ($Item.PSObject.Properties.Name -contains "default") {
        $isDefault = [bool]$Item.default
    }

    if ($All) { return $true }

    if ($nameFilter.Count -gt 0) {
        if ($nameFilter -notcontains $Item.name) { return $false }
        if ($kindFilter.Count -gt 0 -and $kindFilter -notcontains $Item.kind) { return $false }
        return $true
    }

    if ($kindFilter.Count -gt 0) {
        return (($kindFilter -contains $Item.kind) -and $isDefault)
    }

    return $isDefault
}

$scriptRoot = $PSScriptRoot
$packRoot = Join-Path $scriptRoot "packs\$Pack"
$manifest = Join-Path $packRoot "pack.toml"
$targetRoot = Resolve-FullPath $Target

if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) {
    throw "Pack manifest not found: $manifest"
}

$items = Read-PackItems $manifest | Where-Object { Test-Selected $_ }

foreach ($item in $items) {
    $source = [System.IO.Path]::GetFullPath((Join-Path $packRoot $item.source))
    $destination = [System.IO.Path]::GetFullPath((Join-Path $targetRoot $item.target))
    $parent = Split-Path -Parent $destination

    if (-not (Test-Path -LiteralPath $source)) {
        throw "Source not found for $($item.kind) '$($item.name)': $source"
    }

    if ($DryRun) {
        "Would $Mode $($item.kind) '$($item.name)': $destination -> $source"
        continue
    }

    New-Item -ItemType Directory -Path $parent -Force | Out-Null

    if (Test-Path -LiteralPath $destination) {
        $existing = Get-Item -LiteralPath $destination -Force
        if ($existing.LinkType) {
            if ([string]$existing.Target -eq $source) {
                "Already installed: $($item.kind) '$($item.name)'"
                continue
            }
            if ($Force) {
                Remove-Item -LiteralPath $destination -Force
            } else {
                throw "Refusing to replace existing symlink: $destination"
            }
        } else {
            throw "Refusing to overwrite non-link path: $destination"
        }
    }

    if ($Mode -eq "copy") {
        Copy-Item -LiteralPath $source -Destination $destination -Recurse
        "Copied $($item.kind) '$($item.name)' to $destination"
    } else {
        New-Item -ItemType SymbolicLink -Path $destination -Target $source | Out-Null
        "Linked $($item.kind) '$($item.name)' to $destination"
    }
}
