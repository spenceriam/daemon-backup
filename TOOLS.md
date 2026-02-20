# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

---

## Environment

• **Host:** Ubuntu 24.04 LTS (headless server)
• **Location:** /root (running as root — consider non-root for security)
• **OpenClaw:** 2026.2.15 (stable channel, pnpm install)
• **Shell:** bash

---

## Projects Directory

• **Path:** /root/projects
• **factor-cli:** Terminal coding agent (git clone, TypeScript monorepo)
  - Repo: github.com/spenceriam/factor-cli
  - Status: Cloned, not yet tested

---

## GitHub Access

• **Token:** Stored in backup script (ghp_...)
• **Repo:** github.com/spenceriam/kris-kimiclaw (private)
• **Backup script:** /root/.openclaw/backup.sh
• **Schedule:** Every 2 hours via cron

---

## Browser Control

• **Chrome:** /usr/bin/google-chrome (v145)
• **Mode:** Headless, no-sandbox (required for root)
• **Profile:** openclaw (isolated)
• **CDP Port:** 18800

---

## API Keys (Environment)

• **KIMI_API_KEY:** Set in openclaw.json (for kimi-search, kimi-claw)
• **Z.ai API:** Previously used for Impulse (now removed)

---

## tmux Sessions

• Use for long-running processes
• Naming convention: descriptive (e.g., "impulse-factor")
• Detach: Ctrl+B, D
• Reattach: tmux attach -t [name]

---

## Cron Jobs

| Job | Schedule | Purpose |
|-----|----------|---------|
| Backup to GitHub | Every 2 hours | Memory, identity, config |
| Security audit | Daily 9:00 AM | OpenClaw security check |
| Morning briefing | Weekdays 6:30 AM | Weather, news, affirmation |
| Garbage holiday check | Tuesday 8:00 AM | Only if Wednesday is holiday |
| Garbage holiday check | Wednesday 7:00 AM | Only if Wednesday is holiday |

---

## Telegram

• **Bot:** @kris_i_am_bot
• **User:** @spencer_i_am (paired)
• **Format:** Bullet points (tables don't render well)

---

## ClawHub Skills Installed

• weather
• github
• notion
• trello
• obsidian
• slack
• discord
• kimi-search
• kimi-claw
• cron
• healthcheck
• canvas
• tmux
• (and more — see `ls /usr/lib/node_modules/openclaw/skills/`)

---

## Security Notes

• Firewall (UFW): Enabled, SSH only
• SSH: Key-only auth, no password
• OpenClaw: Plugin allowlist active
• Gateway: Localhost-only binding

---

_Last updated: February 17, 2026_