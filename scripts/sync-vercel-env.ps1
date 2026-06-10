param(
  [ValidateSet('production', 'preview', 'development')]
  [string]$Environment = 'production',
  [string]$EnvFile = '.env',
  [switch]$IncludeNonVite
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $EnvFile)) {
  throw "Env file not found: $EnvFile"
}

if (-not (Test-Path '.vercel')) {
  throw 'Current directory is not linked to a Vercel project (.vercel missing). Run: npx vercel link'
}

$npxCmd = (Get-Command npx.cmd -ErrorAction SilentlyContinue).Source
if (-not $npxCmd) {
  throw 'npx.cmd not found. Please install Node.js/npm first.'
}

cmd /c "`"$npxCmd`" vercel --version >nul 2>nul"
if ($LASTEXITCODE -ne 0) {
  throw 'Unable to run Vercel CLI. Please install Node.js/npm and ensure network access to npm registry.'
}

Write-Host "[INFO] Reading $EnvFile and syncing to Vercel environment: $Environment"

$lines = Get-Content $EnvFile
$pairs = @{}

foreach ($line in $lines) {
  $trimmed = $line.Trim()
  if ([string]::IsNullOrWhiteSpace($trimmed)) { continue }
  if ($trimmed.StartsWith('#')) { continue }

  $idx = $trimmed.IndexOf('=')
  if ($idx -lt 1) { continue }

  $key = $trimmed.Substring(0, $idx).Trim()
  $value = $trimmed.Substring($idx + 1)

  if (-not $IncludeNonVite -and -not $key.StartsWith('VITE_')) { continue }

  if ($value.Length -ge 2) {
    if (($value.StartsWith('"') -and $value.EndsWith('"')) -or ($value.StartsWith("'") -and $value.EndsWith("'"))) {
      $value = $value.Substring(1, $value.Length - 2)
    }
  }

  $pairs[$key] = $value
}

if ($pairs.Count -eq 0) {
  throw "No matching env vars found in $EnvFile"
}

Write-Host "[INFO] Variables to sync: $($pairs.Count)"

foreach ($entry in $pairs.GetEnumerator()) {
  $key = $entry.Key
  $value = $entry.Value

  Write-Host "[SYNC] $key"

  cmd /c "`"$npxCmd`" vercel env rm `"$key`" $Environment --yes >nul 2>nul"

  $tempValueFile = [System.IO.Path]::GetTempFileName()
  try {
    [System.IO.File]::WriteAllText($tempValueFile, $value)
    cmd /c "type `"$tempValueFile`" | `"$npxCmd`" vercel env add `"$key`" $Environment >nul 2>nul"
  }
  finally {
    Remove-Item $tempValueFile -Force -ErrorAction SilentlyContinue
  }

  if ($LASTEXITCODE -ne 0) {
    throw "Failed syncing env var: $key"
  }
}

Write-Host '[DONE] Vercel env sync completed successfully.'
Write-Host '[NEXT] Trigger a fresh deploy: npx vercel --prod'
