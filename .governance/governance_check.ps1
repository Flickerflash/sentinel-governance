# Sentinel Governance Check (PowerShell)
$ErrorActionPreference = "SilentlyContinue"

Write-Host "[Sentinel] Running Integrity Sweep..." -ForegroundColor Cyan

# 1. Secret scanning
# We use a pattern to detect potential API keys/secrets
$secretPattern = "AIza[0-9A-Za-z]{35}|sk-[A-Za-z0-9]{32}"

# Get files, explicitly excluding problematic directories
$files = Get-ChildItem -Recurse -File -Exclude .git, .governance, .github, .gitignore, .DS_Store, node_modules, dist

$secretsFound = $false

foreach ($file in $files) {
    if (Select-String -Path $file.FullName -Pattern $secretPattern -Quiet) {
        Write-Host "[!] CRITICAL: Potential secret found in $($file.FullName)" -ForegroundColor Red
        $secretsFound = $true
    }
}

if ($secretsFound) { exit 1 }

# 2. Auto-healing directory check
$requiredDirs = @("projects", "lab", "knowledge-base", "archive")
foreach ($dir in $requiredDirs) {
    if (-not (Test-Path $dir)) {
        Write-Host "[*] Creating missing directory: $dir" -ForegroundColor Yellow
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }
}

# 3. Governance document checks (Warning only, do not fail)
$requiredFiles = @("README.md", "LICENSE", "CONTRIBUTING.md", "SECURITY.md")
foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file)) {
        Write-Host "[!] Warning: Missing governance file: $file" -ForegroundColor Yellow
    }
}

Write-Host "[OK] Integrity Passed." -ForegroundColor Green
exit 0
