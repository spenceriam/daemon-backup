# PROJECTS.md - Active Context

## Jelico
**Objective:** Desktop AI assistant with persistent memory and personality
**Current Stage:** Bug fixing - 3 of 12 issues completed today
**Constraints:** Electron + React + TypeScript, multi-provider LLM support
**Key Decisions:**
- Built-in Todo panel vs external files (Issue #48) - COMPLETE (PR #66)
- Permission scoping exact-match (Issue #57) - COMPLETE (PR #67)  
- Artifact thumbnail previews (Issue #32) - COMPLETE (PR #66)
- Git work trees (Issue #36) - COMPLETE (PR #67)
- Clickable screenshots (Issue #41) - COMPLETE (PR #68)
- Programmatic tool calling (Issue #61) - PENDING
**Next Action:** Complete remaining 9 open issues

## Job Hunt
**Objective:** Find AI/LLM role (Solutions Engineer, AI Deployment, Product Manager)
**Current Stage:** Active search with daily cron job
**Constraints:** Remote preferred, US-based companies
**Key Decisions:**
- Adzuna API blocked (network issue)
- Using kimi_search + web_search instead
- Daily 8 AM CST job alerts with URLs
**Next Action:** Review daily job matches, apply to OpenAI/Anthropic roles

## OpenClaw Setup
**Objective:** Comprehensive personal assistant automation
**Current Stage:** Core functionality complete, version monitoring active
**Constraints:** Browser control intermittent, plugin config
**Key Decisions:**
- Telegram primary channel (streamMode disabled for clarity)
- Kimi K2.5 default model
- Cron jobs: morning briefing, security audit, job search, version check
- ZERO ERROR PROTOCOL v2.0 implemented
**Next Action:** Continue Jelico development, monitor for OpenClaw updates

---
*Last updated: 2026-02-20*
