# ERRORS.md - Anti-Repeat System

## 2026-02-19

### Error: Adzuna API Connection Timeout
**What went wrong:** API calls to api.adzuna.com timeout (exit code 28, 100% packet loss)
**Why:** Server/VPS IP range blocked by Adzuna (datacenter IP filtering)
**Correct pattern:** Use kimi_search and web_search as fallback
**Prevention:** Check API accessibility before signing up for services

### Error: Subagent Conflict on Jelico PRs
**What went wrong:** Subagent and I both created branches with same name, caused push conflicts
**Why:** Subagent started working before I took over, no coordination
**Correct pattern:** Check for existing branches before creating new ones
**Prevention:** Clear communication about who owns which task

### Error: Copilot CLI --thinking Flag
**What went wrong:** Used --thinking flag which doesn't exist in Copilot CLI
**Why:** Assumed flag based on other tools
**Correct pattern:** Check copilot --help before using flags
**Prevention:** Always verify CLI options

---
*Last updated: 2026-02-19*
