# DECISIONS.md - Strategic Memory

## 2026-02-19

### Decision: Use Copilot CLI as Pair Programming Partner
**Context:** Spencer wants two AI minds collaborating to prevent bias/hallucinations
**Decision:** I drive the conversation with Copilot CLI - present issue, get analysis, challenge/approve, iterate, then implement
**Alternatives:** Subagents for coding (rejected - wants direct collaboration)
**Trade-offs:** Slower but higher quality, prevents single-AI bias

### Decision: Cognitive Infrastructure Protocol
**Context:** Spencer shared structured memory system
**Decision:** Implement /mind/ directory with PROFILE, PROJECTS, DECISIONS, ERRORS, and daily logs
**Alternatives:** Rely on MEMORY.md only (rejected - not structured enough)
**Trade-offs:** More overhead but better long-term memory and context

### Decision: Minimal vs Comprehensive Fixes
**Context:** Issue #57 permission scoping - minimal fix vs full refactor
**Decision:** Subagent implemented comprehensive fix with PermissionScope type
**Alternatives:** Minimal surgical edits (Copilot's first suggestion)
**Trade-offs:** More code change but better long-term architecture

### Decision: ZERO ERROR PROTOCOL v2.0
**Context:** Spencer wants higher reliability, reduced hallucinations
**Decision:** Implement behavioral constraints: VERIFY BEFORE OUTPUT, validate logic, check assumptions, flag uncertainty, no fabrication
**Alternatives:** Continue without formal protocol (rejected - too many errors)
**Trade-offs:** More internal checks but higher accuracy and trust

---
*Last updated: 2026-02-20*
