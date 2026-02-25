#!/bin/bash
# Check for OpenClaw updates and notify

CURRENT_VERSION=$(openclaw --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+[^ ]*' || echo "unknown")
LATEST_VERSION=$(curl -s "https://registry.npmjs.org/openclaw" | python3 -c "import sys, json; print(json.load(sys.stdin)['dist-tags']['latest'])")

if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ] && [ "$LATEST_VERSION" != "" ]; then
    echo "🔄 OpenClaw Update Available"
    echo "Current: $CURRENT_VERSION"
    echo "Latest: $LATEST_VERSION"
    echo ""
    echo "Run: openclaw update"
else
    echo "✅ OpenClaw is up to date ($CURRENT_VERSION)"
fi
