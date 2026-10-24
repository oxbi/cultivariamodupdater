<#
Cultivaria one-click updater (Windows PowerShell 5.1, nothing to install).
Brings mods/, config/ and our jar in a .minecraft folder to the pack version in manifest.json.
Touches ONLY files the pack owns (listed in the manifest, or recorded as installed by a previous run).
Every replaced or removed file is first copied to <gamedir>\cultivaria-update-backup\<time>\.
Any failed download or check stops the run before a single file of the game folder is changed.
Usage: update-cultivaria.ps1 [-GameDir <.minecraft>] [-BaseUrl <https://... or folder>] [-CheckOnly]
#>
param(
    [string]$GameDir = (Join-Path $env:APPDATA '.minecraft'),
    [string]$BaseUrl,
    [switch]$CheckOnly
)
$ErrorActionPreference = 'Stop'
# PS 5.1: the progress bar slows big downloads many times over, and https hosts need TLS 1.2
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

function Stop-Update($msg) { Write-Host "UPDATE FAILED: $msg" -ForegroundColor Red; exit 1 }

try {
    if (-not $BaseUrl) {
        $cfg = Join-Path $PSScriptRoot 'updater.config.json'
        if (-not (Test-Path $cfg)) { Stop-Update "no -BaseUrl given and $cfg is missing" }
        $BaseUrl = (Get-Content $cfg -Raw | ConvertFrom-Json).base_url
        if (-not $BaseUrl) { Stop-Update "$cfg has no base_url" }
    }
    $BaseUrl = $BaseUrl.TrimEnd('/', '\')
    if (-not (Test-Path (Join-Path $GameDir 'mods'))) { Stop-Update "$GameDir has no mods folder - is that the right .minecraft? (use -GameDir)" }
    $GameDir = (Resolve-Path $GameDir).Path

    $isWeb = $BaseUrl -match '^https?://'
    function Fetch($rel, $dest) {
        $src = "$BaseUrl/$rel"
        try {
            if ($isWeb) { Invoke-WebRequest -Uri $src -OutFile $dest -UseBasicParsing }
            else { Copy-Item -LiteralPath ($src -replace '/', '\') -Destination $dest -Force }
        } catch { Stop-Update "could not get $src : $($_.Exception.Message)" }
    }
    function Sha1($p) { (Get-FileHash -LiteralPath $p -Algorithm SHA1).Hash.ToLower() }
    function Local($rel) { Join-Path $GameDir ($rel -replace '/', '\') }

    $stage = Join-Path $env:TEMP ("cultivaria-update-" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $stage | Out-Null
    try {
        Fetch 'manifest.json' (Join-Path $stage 'manifest.json')
        $m = Get-Content (Join-Path $stage 'manifest.json') -Raw -Encoding UTF8 | ConvertFrom-Json
        if (-not $m.pack_version -or -not $m.files) { Stop-Update "manifest.json is not a Cultivaria manifest" }

        # self-update: the manifest says which version of this script it expects
        if ($m.updater_sha1 -and (Sha1 $PSCommandPath) -ne $m.updater_sha1) {
            Write-Host "Updating the updater itself first..."
            $newSelf = Join-Path $stage 'self.ps1'
            Fetch 'update-cultivaria.ps1' $newSelf
            if ((Sha1 $newSelf) -ne $m.updater_sha1) { Stop-Update "update-cultivaria.ps1 on the server does not match its manifest" }
            Copy-Item -LiteralPath $newSelf -Destination $PSCommandPath -Force
            $again = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-GameDir', $GameDir, '-BaseUrl', $BaseUrl)
            if ($CheckOnly) { $again += '-CheckOnly' }
            & powershell @again
            exit $LASTEXITCODE
        }

        $statePath = Join-Path $GameDir 'cultivaria-pack-state.json'
        $oldOwned = @()
        $oldVersion = '(none)'
        if (Test-Path $statePath) {
            $st = Get-Content $statePath -Raw -Encoding UTF8 | ConvertFrom-Json
            $oldOwned = @($st.files); $oldVersion = $st.pack_version
        }

        $want = @{}; foreach ($f in $m.files) { $want[$f.path] = $f }

        # settings files (config/, shader settings): a player's own copy is kept unless the pack changed that file
        # (manifest "since") after the version this PC last updated to; delete the file to get the pack's copy back
        function IsSetting($p) { $p -like 'config/*' -or $p -like 'shaderpacks/*.txt' }
        function ChangedSince($since, $old) {
            try { return ([version]$since) -gt ([version]$old) } catch { return $true }  # '(none)' = first run: the pack's copy
        }
        # files to download: missing or different from the manifest
        $toGet = @(); $kept = @()
        foreach ($f in $m.files) {
            $lp = Local $f.path
            if ($f.seed) { if (-not (Test-Path -LiteralPath $lp)) { $toGet += $f }; continue }  # seed files: only installed when missing, never overwritten
            if (-not (Test-Path -LiteralPath $lp)) { $toGet += $f; continue }
            if ((Sha1 $lp) -eq $f.sha1) { continue }
            if ((IsSetting $f.path) -and $f.since -and -not (ChangedSince $f.since $oldVersion)) { $kept += $f.path; continue }
            $toGet += $f
        }
        if ($kept.Count -gt 0) {
            Write-Host "Kept your own copy of $($kept.Count) settings file(s) (delete one to get the pack's version on the next run):"
            $kept | ForEach-Object { "  keep   $_" }
        }
        # files to remove: owned before / retired / matching an owned pattern, and no longer in the manifest
        $cand = New-Object System.Collections.Generic.HashSet[string]
        foreach ($p in $oldOwned) { [void]$cand.Add($p) }
        foreach ($p in @($m.retired)) { if ($p) { [void]$cand.Add($p) } }
        foreach ($g in @($m.owned_globs)) {
            if (-not $g) { continue }
            $dir = Split-Path ($g -replace '/', '\') -Parent
            $dp = Join-Path $GameDir $dir
            if (Test-Path $dp) {
                Get-ChildItem -LiteralPath $dp -File | Where-Object { "$dir\$($_.Name)" -like ($g -replace '/', '\') } |
                    ForEach-Object { $rp = ($dir + '/' + $_.Name) -replace '\\', '/'; [void]$cand.Add($rp) }
            }
        }
        $toRemove = @($cand | Where-Object { -not $want.ContainsKey($_) -and (Test-Path -LiteralPath (Local $_)) })

        $newState = @{ pack_version = $m.pack_version; files = @($m.files | ForEach-Object { $_.path }) }
        if ($toGet.Count -eq 0 -and $toRemove.Count -eq 0) {
            $newState | ConvertTo-Json -Depth 4 | Set-Content $statePath -Encoding UTF8
            Write-Host "Already up to date (pack $($m.pack_version))." -ForegroundColor Green
            exit 0
        }
        Write-Host "Pack $oldVersion -> $($m.pack_version): $($toGet.Count) file(s) to download, $($toRemove.Count) old file(s) to remove."
        if ($CheckOnly) { $toGet | ForEach-Object { "  get    $($_.path)" }; $toRemove | ForEach-Object { "  remove $_" }; exit 0 }

        # 1. download and verify everything first
        $i = 0
        foreach ($f in $toGet) {
            $i++
            $dest = Join-Path $stage ("f" + $i)
            Fetch ("files/" + $f.path) $dest
            if ((Get-Item $dest).Length -ne $f.size) { Stop-Update "$($f.path): downloaded size $((Get-Item $dest).Length), expected $($f.size)" }
            if ((Sha1 $dest) -ne $f.sha1) { Stop-Update "$($f.path): checksum does not match the manifest" }
            Write-Host ("  [{0}/{1}] {2}" -f $i, $toGet.Count, $f.path)
        }
        # 2. apply: back up what is replaced/removed, then write
        $bk = Join-Path $GameDir ("cultivaria-update-backup\" + (Get-Date -Format 'yyyyMMdd-HHmmss'))
        function Backup($rel) {
            $lp = Local $rel
            if (Test-Path -LiteralPath $lp) {
                $bp = Join-Path $bk ($rel -replace '/', '\')
                New-Item -ItemType Directory -Force -Path (Split-Path $bp -Parent) | Out-Null
                Copy-Item -LiteralPath $lp -Destination $bp -Force
            }
        }
        foreach ($r in $toRemove) {
            Backup $r
            try { Remove-Item -LiteralPath (Local $r) -Force } catch { Stop-Update "could not remove $r (is Minecraft still running?): $($_.Exception.Message)" }
            Write-Host "  removed $r"
        }
        $i = 0
        foreach ($f in $toGet) {
            $i++
            Backup $f.path
            $lp = Local $f.path
            New-Item -ItemType Directory -Force -Path (Split-Path $lp -Parent) | Out-Null
            try { Copy-Item -LiteralPath (Join-Path $stage ("f" + $i)) -Destination $lp -Force } catch { Stop-Update "could not write $($f.path) (is Minecraft still running?): $($_.Exception.Message)" }
        }
        $newState | ConvertTo-Json -Depth 4 | Set-Content $statePath -Encoding UTF8
        Write-Host "Updated to pack $($m.pack_version). Old files are in $bk" -ForegroundColor Green
    } finally {
        Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue
    }
} catch {
    Stop-Update $_.Exception.Message
}
