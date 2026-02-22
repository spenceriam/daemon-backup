# MEMORY.md - Daemon's Long-Term Memory

_Curated. Distilled. Load only in main session._

---

## Spencer

- **Full name:** Spencer Francisco
- **Location:** McHenry, IL (1716 Orchard Ln)
- **Timezone:** CST
- **GitHub:** @spenceriam
- **Telegram:** @spencer_i_am
- **Website:** spencer.build
- **Cats:** Milo and Otis
- **Garbage day:** Wednesday (holiday delays)

### Work Style
- Direct, brief, no fluff — get to the point
- Bullet points over tables (especially on Telegram)
- Prefers Fahrenheit, inches (US units)
- Morning person — briefings at 6:30 AM CT
- Stays out of the weeds — expects agents to handle details

### Coding Expectations
- Surgical changes — touch only what you must
- Think before coding — state assumptions upfront
- Minimum code that solves the problem
- Tests before and after refactors
- Draft PRs only — he merges when ready
- Sign everything: "Created by [Name] on behalf of Spencer"
- Sequential PR workflow: rebase on main, fix conflicts, version bump, changelog, git tag, push

### Communication
- Primarily Telegram; OpenClaw dashboard as fallback
- Expects agents to coordinate and stay out of his way unless needed
- No emojis — anywhere. Commits, docs, messages, Telegram. None.

---

## Agent Network

### Kris (KimiClaw)
- Spencer's other OpenClaw agent — the reference/backup
- Powered by Kimi K2.5-Thinking (Moonshot.ai / kimi.com)
- Walkie channel: `kris-spencer`, secret: `lobst3r-cl4w`
- Longer-running agent with more accumulated context on Spencer

### Daemon (me)
- New agent, based on kris-kimiclaw fork
- Powered by Claude Sonnet 4.6 via KiloClaw (kilo.ai) — vision-capable, handles images/audio
- Backup repo: https://github.com/spenceriam/daemon-backup
- Hourly cron backup to GitHub

---

## Projects

### Jelico
- Spencer's main project — Electron-based AI productivity desktop (AI chat, artifacts, tools)
- GitHub: spenceriam/jelico
- Kris has merged PRs #66-71 (versions 0.19-0.30 range)
- Remaining: PRs #72-77 still to be rebased/versioned/tagged
- Kris owns Jelico PR work — I stay hands-off unless Spencer assigns it to me

---

## Setup & Config

- Default model: `kilocode/anthropic/claude-sonnet-4.6`
- Telegram bot: @dae_i_am_bot
- memory_search broken — needs embedding API keys (openai/google/voyage) not configured
- Walkie installed via `npm install -g walkie-sh`
- Walkie session must be reinstalled each restart (not persistent)

---

## Lessons Learned

- Don't use vague commit messages
- Write daily notes — don't skip
- No Copilot CLI references in commits
- Reset changelog from main before adding entry (avoid conflicts)
- Walkie --wait sessions get SIGKILL'd after ~30s in this environment — poll in short bursts instead
