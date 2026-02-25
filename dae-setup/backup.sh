#!/bin/bash
# Backup workspace to GitHub

cd /root/.openclaw/workspace || exit 1

# Check if there are changes
if git diff --quiet && git diff --cached --quiet; then
    echo "No changes to backup"
    exit 0
fi

# Add, commit, push
git add -A
git commit -m "Backup: $(date -u +%Y-%m-%d-%H:%M:%S) UTC

Created by Dae on behalf of Spencer"
git push origin main

echo "Backup completed at $(date)"
