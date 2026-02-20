# Jelico Analysis - Quick Reference

## Open Issues Summary (15 total)

### Critical (P0) - 2 issues
- #57: Permission scoping too broad (SECURITY)
- #48: Todo panel state drift (DATA CONSISTENCY)

### High (P1) - 5 issues
- #56: Context window limits inaccurate
- #55: Provider/model selector non-interactive
- #54: Editor view rendering issues
- #50: OpenAI compatible provider fails on Minimax

### Medium (P2) - 3 issues
- #60: Streaming rendering overflows
- #59: Canvas divider stops too early
- #58: Default typography baseline

### Enhancements - 6 issues
- #61: Programmatic tool calling
- #53: Diff view for file edits
- #51: Minimax Coding Plan provider
- #41: Clickable screenshot previews
- #36: Git work tree init option
- #32: Artifact screenshot thumbnails

---

## Security Issues Found

| Severity | Issue | Location |
|----------|-------|----------|
| 🔴 Critical | Permission wildcards allow any file write | `permissionChecker.ts:156-162` |
| 🔴 Critical | XSS via dangerouslySetInnerHTML | `MermaidViewer.tsx:175,240`, `CanvasPanel.tsx:435` |
| 🟡 Medium | Command injection in execute_command | `ai.ts` (shell execution) |
| 🟡 Medium | Path traversal possible in sandbox | `ai.ts` (path sanitization) |

---

## Code Quality Issues

| Issue | Count | Examples |
|-------|-------|----------|
| `any` type usage | 50+ | `ai.ts`, `chat.ts` |
| TODO comments | 3 | `PermissionsSettings.tsx`, `ai.ts` |
| Code duplication | 5+ | Permission logic, token estimation |
| File too long | 3 | `ai.ts` (~3000 lines), `chat.ts` (~2000 lines), `subagents.ts` (~2300 lines) |

---

## Architecture Problems

1. **Store Coupling** - `chat.ts` imports 7 other stores
2. **IPC Complexity** - `ai.ts` handles everything (3000+ lines)
3. **No DAL** - Direct DB access from IPC handlers
4. **Renderer-only State** - Todos in localStorage, not database

---

## Performance Bottlenecks

1. **Token estimation** - Rough 4 chars/token approximation
2. **State updates** - Every streaming chunk triggers re-render
3. **Memory leaks** - Sub-agent maps never cleaned
4. **No pagination** - All messages loaded into memory

---

## Key Files to Review

| File | Lines | Purpose | Issues |
|------|-------|---------|--------|
| `electron/ipc/ai.ts` | ~3000 | AI streaming, tools | Too long, complex, security |
| `src/stores/chat.ts` | ~2000 | Chat state | Coupling, performance |
| `electron/services/subagents.ts` | ~2300 | Sub-agent mgmt | Memory leaks, complexity |
| `electron/services/permissionChecker.ts` | ~300 | Permissions | Security (wildcards) |
| `src/stores/context.ts` | ~200 | Context window | Inaccurate detection |

---

## Recommended Fix Order

### Week 1 (Security)
1. Fix permission wildcards (#57)
2. Add XSS sanitization
3. Improve path traversal protection

### Week 2 (Stability)
4. Fix todo state sync (#48)
5. Fix provider selector (#55)
6. Improve context detection (#56)

### Week 3 (Performance)
7. Throttle streaming updates
8. Add message pagination
9. Fix sub-agent memory leaks

### Week 4 (Refactoring)
10. Extract tools from ai.ts
11. Split chat store
12. Add proper DAL

---

## Testing Checklist

- [ ] Permission bypass attempts
- [ ] XSS payloads in artifacts
- [ ] Path traversal in sandbox
- [ ] Large conversation handling (10K+ messages)
- [ ] Multiple concurrent sub-agents
- [ ] Provider switching scenarios
- [ ] Context compaction edge cases

---

## Files Generated

1. `jelico-bug-report.md` - Full analysis
2. `jelico-technical-deep-dive.md` - Implementation details
3. `jelico-quick-reference.md` - This file

---

*Ready for Copilot CLI collaboration*
