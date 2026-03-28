#!/bin/bash
set -e
echo "[Sentinel] Running Integrity Sweep..."
# Check for secrets (Basic check)
if grep -rnE "AIza[0-9A-Za-z]{35}|sk-[A-Za-z0-9]{32}" . --exclude-dir=.git; then
    echo "[!] CRITICAL: Potential secret found."
    exit 1
fi
# Check for directory existence
for dir in "projects" "lab" "knowledge-base" "archive"; do
    if [ ! -d "$dir" ]; then echo "[!] Missing dir: $dir"; exit 1; fi
done
echo "[OK] Integrity Passed."
