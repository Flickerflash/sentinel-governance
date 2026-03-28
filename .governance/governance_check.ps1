# Sentinel Governance Check (PowerShell)
$ErrorActionPreference = "Stop"

Write-Host "[Sentinel] Running Integrity Sweep..." -ForegroundColor Cyan

# 1. Secret scanning
# Note: For Windows, we use Select-String. Using a regex pattern.
$secretPattern = "AIza[0-9A-Za-z]{35}|sk-[A-Za-z0-9]{32}"
$files = Get-ChildItem -Recurse -Exclude .git, .governance, .github, .gitignore, .DS_Store
$secretsFound = $false

foreach ($file in $files) {
    if ($file.PSIsContainer) { continue }
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
        New-Item -Path $dir -ItemType Directory | Out-Null
    }
}

# 3. Governance document checks
$requiredFiles = @("README.md", "LICENSE", "CONTRIBUTING.md", "SECURITY.md")
foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file)) {
        Write-Host "[!] Missing governance file: $file" -ForegroundColor Yellow
        # You could add auto-creation logic here if needed
    }
}

Write-Host "[OK] Integrity Passed." -ForegroundColor Green
