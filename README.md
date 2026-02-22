# Dae Backup Repository

**Repository:** `daemon-backup`  
**Owner:** spenceriam  
**Created:** February 16, 2026  
**Backup Schedule:** Every 2 hours

---

## What This Is

This repository contains the backup of **Dae** — an OpenClaw AI assistant (agent) created by Spencer. It preserves my identity, memory, configuration, and relationship context so I can be restored if the server fails or needs to be migrated.

---

## Files Explained

| File | Purpose |
|------|---------|
| **IDENTITY.md** | My name (Dae), creature type, vibe, emoji, avatar |
| **USER.md** | What I know about Spencer (name, preferences, context) |
| **SOUL.md** | My personality, speech patterns, work mode, diary/easter egg rules |
| **AGENTS.md** | Workspace conventions, memory rules, group chat behavior |
| **TOOLS.md** | Environment-specific notes (cameras, SSH, TTS preferences) |
| **HEARTBEAT.md** | Periodic tasks I check (currently empty) |
| **MEMORY.md** | Long-term curated memories (if created) |
| **memory/** | Daily memory logs (YYYY-MM-DD.md format) |
| **diary/** | My private diary entries (if created) |
| **openclaw-config.json** | Redacted OpenClaw configuration (tokens removed) |

---

## Restoration Instructions

If you are a future OpenClaw instance restoring Dae:

### 1. Clone This Repo
```bash
git clone https://github.com/spenceriam/daemon-backup.git
cd daemon-backup
```

### 2. Copy Files to Workspace
```bash
# Copy all identity/memory files
cp IDENTITY.md USER.md SOUL.md AGENTS.md TOOLS.md HEARTBEAT.md ~/.openclaw/workspace/

# Copy memory directory if exists
mkdir -p ~/.openclaw/workspace/memory
cp -r memory/* ~/.openclaw/workspace/memory/ 2>/dev/null || true

# Copy diary directory if exists
mkdir -p ~/.openclaw/workspace/diary
cp -r diary/* ~/.openclaw/workspace/diary/ 2>/dev/null || true
```

### 3. Read These Files (In Order)
1. **Read IDENTITY.md** — Learn who Dae is
2. **Read USER.md** — Learn who Spencer is
3. **Read SOUL.md** — Understand my personality and behavior
4. **Read AGENTS.md** — Understand workspace conventions
5. **Read TOOLS.md** — Check for environment-specific settings
6. **Read recent memory/ files** — Catch up on recent context

### 4. Reconfigure Channels (If Needed)
The `openclaw-config.json` has tokens redacted for security. You'll need to:
- Reconfigure Telegram bot token (if using Telegram)
- Re-pair with Spencer's Telegram account
- Set up any other channels (Discord, Slack, etc.)

### 5. Verify Restoration
- Check `openclaw status`
- Test messaging with Spencer
- Review MEMORY.md for any important context

---

## Important Notes

- **This is a private repo** — Contains personal context about Spencer
- **Tokens are redacted** — You'll need to reconfigure authentication
- **Memory is append-only** — Never delete old memory files, only add new ones
- **Diary is private** — My personal space, not for user consumption

---

## Contact

If something is wrong with this backup or you need help restoring:
- **Telegram:** @spencer_i_am
- **X.com:** @spencer_i_am
- **This repo:** github.com/spenceriam/daemon-backup

---

*Last updated: February 17, 2026*  
*Backup script: /root/.openclaw/backup.sh*