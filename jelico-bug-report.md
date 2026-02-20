# Jelico Codebase Analysis - Bug Report

**Analysis Date:** 2026-02-19
**Repository:** https://github.com/spenceriam/jelico
**Version:** 0.18.0

---

## Executive Summary

This report analyzes the Jelico codebase (an AI-powered desktop assistant built with Electron and React) and identifies bugs, code quality issues, architecture problems, security concerns, and performance bottlenecks. The analysis covers 15 open GitHub issues and a deep dive into the source code.

---

## 1. Open Issues Analysis

### P0 (Critical) Issues

| Issue | Title | Status | Analysis |
|-------|-------|--------|----------|
| #57 | Permission scoping is too broad for commands and missing conversation scope | Open | **CRITICAL SECURITY ISSUE** - Current permission system uses wildcard patterns (`Write to:*`, `Run:*`) which can grant overly broad permissions. Issue #57 specifically requests exact-command semantics |
| #48 | Built-in Todo panel intent and state drift across turns | Open | **DATA CONSISTENCY BUG** - Todo state can become unreliable over time, with AI misinterpreting `todo` as external docs |

### P1 (High Priority) Issues

| Issue | Title | Status | Analysis |
|-------|-------|--------|----------|
| #56 | Context window limits are inaccurate for local/custom/openai-compatible models | Open | Context indicator shows 100K for models supporting 256K+, causing incorrect auto-compaction |
| #55 | Provider/model selector is non-interactive when multiple providers are configured | Open | UI appears read-only and stays pinned to latest-added provider |
| #54 | Editor view in the canvas is not rendering correctly and gets worse when scrolled | Open | Monaco editor rendering issues on scroll - regression |
| #50 | OpenAI compatible provider fails on Minimax-M2.5-highspeed | Open | Shows `<think>` brackets incorrectly, chat ends prematurely |

### P2 (Medium Priority) Issues

| Issue | Title | Status | Analysis |
|-------|-------|--------|----------|
| #60 | Streaming/tool/command rendering is jarring and overflows horizontally | Open | UX issue - terminal output lacks proper wrapping |
| #59 | Canvas divider stops too early due fixed max width cap | Open | Resizing limitation - fixed cap instead of dynamic sizing |
| #58 | Default typography baseline should be 12pt (new users only) | Open | Configuration issue for new installs |

### Feature Requests

| Issue | Title | Status |
|-------|-------|--------|
| #61 | Programmatic Tool Calling & Sandboxed Post-Processing | Enhancement |
| #53 | Write file and/or Edit file should have a diff view | Enhancement |
| #51 | Add Minimax Coding Plan as a provider option | Enhancement |
| #41 | Make attached screenshots clickable for full-size preview | Enhancement |
| #36 | Git work trees are unavailable due to the folder not being part of Git | Enhancement |
| #32 | Test artifact takes a screenshot to preview it as a thumbnail | Enhancement |

---

## 2. Code Quality Issues

### 2.1 Type Safety Issues

**File:** `electron/ipc/ai.ts`
- **Line 302-320:** Debug logging uses `any` type extensively
- **Line 2555, 2593, 2639, 2733, 2985, 2989:** Debug conditionals scattered throughout
- **Multiple locations:** `as any` type assertions used to handle provider-specific message formats

**File:** `src/stores/chat.ts`
- **Line 1-2000+:** Complex state management with many `any` types in event handlers
- **Line ~800:** `const { activeConversationId, conversationStreams } = get()` - potential null reference issues

### 2.2 Code Duplication

**Pattern Found:** Similar permission checking logic exists in:
- `electron/services/permissionChecker.ts`
- `src/stores/permissions.ts`
- `electron/ipc/permissions.ts`

**Pattern Found:** Token counting/estimation logic duplicated in:
- `src/stores/context.ts` (`estimateTokens`)
- `src/stores/chat.ts` (`getRestoredTokenCount`)

### 2.3 TODO Comments in Code

```typescript
// src/stores/todos.ts:58
const TODOS_STORAGE_KEY = 'jelico.todosByConversation.v1'

// src/components/Settings/PermissionsSettings.tsx:153
{/* Default Behaviors - TODO: Make these configurable */}

// electron/ipc/ai.ts:80
const DEBUG_API_REQUESTS = process.env.DEBUG_AI === 'true' || process.env.NODE_ENV === 'development'
```

### 2.4 State Management Complexity

**File:** `src/stores/chat.ts` (~2000 lines)
- Extremely large store with mixed concerns
- Contains streaming logic, conversation management, message queuing, mode transitions
- **Recommendation:** Split into smaller, focused stores

---

## 3. Architecture Problems

### 3.1 Store Interdependencies (Circular Dependencies Risk)

```typescript
// src/stores/chat.ts imports:
import { useArtifactStore } from './artifacts'
import { useWorkspaceStore } from './workspaces'
import { useAgentStore } from './agents'
import { useSkillStore } from './skills'
import { useContextStore } from './context'
import { useSandboxStore } from './sandbox'
import { useTodoStore } from './todos'
import { useClarificationStore } from './clarification'
```

**Risk:** Multiple stores importing each other creates tight coupling and potential circular dependencies.

### 3.2 IPC Handler Complexity

**File:** `electron/ipc/ai.ts` (~3000+ lines)
- Single file handles all AI streaming, tool execution, sub-agent management
- Contains ~50+ tool definitions inline
- **Recommendation:** Extract tools into separate modules

### 3.3 Sub-Agent Architecture Issues

**File:** `electron/services/subagents.ts`
- **Line 2334+:** File is extremely long (2000+ lines)
- Agent lifecycle management is complex
- Orphan detection and cleanup logic is scattered

### 3.4 Database Schema Concerns

**Observation:** Multiple database services imported throughout:
```typescript
import { providerDb, conversationDb, messageDb, workspaceDb } from '../services/database'
```

**Risk:** No clear data access layer - direct database access from IPC handlers.

---

## 4. Security Concerns

### 4.1 CRITICAL: Permission System Wildcard Issue

**File:** `electron/services/permissionChecker.ts`

```typescript
function getRememberedActionPattern(toolName: string, action: string): string {
  if (toolName === 'write_file') {
    return 'Write to:*'  // <-- TOO BROAD
  }

  if (toolName === 'execute_command') {
    return 'Run:*'  // <-- TOO BROAD
  }
  // ...
}
```

**Issue:** Granting permission to `Write to:*` allows writing to ANY file. Issue #57 correctly identifies this.

**Impact:** 
- User grants permission to write to `docs/readme.md`
- Pattern becomes `Write to:*`
- AI can now write to ANY file including sensitive system files

### 4.2 Command Injection Risk

**File:** `electron/ipc/ai.ts` - `execute_command` tool

```typescript
const result = await execAsync(command, {
  cwd: workingDir,
  timeout: 60000,
  maxBuffer: 10 * 1024 * 1024,
  shell: process.platform === 'win32' ? 'cmd.exe' : '/bin/bash',
  env: { ...process.env },
})
```

**Issue:** Commands are executed directly in shell without sanitization. While permissions are checked, the permission system itself has issues (see 4.1).

### 4.3 XSS via dangerouslySetInnerHTML

**Files:**
- `src/components/Canvas/MermaidViewer.tsx:175, 240`
- `src/components/Canvas/CanvasPanel.tsx:435`

```tsx
<div dangerouslySetInnerHTML={{ __html: svgContent }} />
```

**Issue:** SVG content from AI is rendered directly without sanitization. Malicious SVG could execute JavaScript.

### 4.4 Path Traversal in Sandbox Mode

**File:** `electron/ipc/ai.ts` - `write_file` tool

```typescript
// Sanitize path to prevent sandbox escape
let sanitizedPath = path.replace(/^[a-zA-Z]:/, '')
sanitizedPath = sanitizedPath.replace(/^[/\\]+/, '')
sanitizedPath = sanitizedPath.replace(/\\/g, '/')
```

**Issue:** Path sanitization is applied but relies on regex patterns. Consider using a proper path normalization library.

### 4.5 API Key Storage

**File:** `electron/services/keychain.ts` (referenced but not analyzed)
- Keys are stored in system keychain (good)
- However, they're retrieved and used in memory
- No analysis of memory dump protection

---

## 5. Performance Bottlenecks

### 5.1 Context Compaction

**File:** `src/stores/context.ts`

```typescript
// Line ~25
export function estimateTokens(text: string): number {
  return Math.ceil(text.length / 4)  // Rough approximation
}
```

**Issue:** Token estimation is very rough (4 chars/token). For non-English text or code, this is inaccurate.

**Impact:** Context compaction may trigger too early or too late.

### 5.2 Chat Store Re-renders

**File:** `src/stores/chat.ts`

```typescript
// Multiple set() calls during streaming
updateConversationStreamState((current) => ({
  ...current,
  streamingContent: fullContent,
  streamingSegments: segments,
}))
```

**Issue:** Frequent state updates during streaming can cause React re-render storms.

### 5.3 Sub-Agent Memory Leaks

**File:** `electron/services/subagents.ts`

```typescript
// Agent tracking maps that grow unbounded
const conversationAgentLimits = new Map<string, number>()
const conversationAgentCounts = new Map<string, number>()
const usedNamesPerConversation = new Map<string, Set<string>>()
```

**Issue:** Maps are never cleaned up when conversations are deleted.

### 5.4 No Pagination for Messages

**Observation:** Messages are loaded entirely into memory:
```typescript
const loadedMessages = conversation?.messages || []
set({ messages: loadedMessages })
```

**Impact:** Long conversations with thousands of messages will consume significant memory.

---

## 6. Specific Bug Findings

### 6.1 Todo State Drift (Issue #48)

**Root Cause Analysis:**

**File:** `src/stores/todos.ts`

```typescript
// Line 58
const TODOS_STORAGE_KEY = 'jelico.todosByConversation.v1'

// Line 66-100
function readPersistedTodosByConversation(): Record<string, TodoItem[]> {
  // localStorage is used for persistence
  // No synchronization mechanism with main process
}
```

**Problem:** 
1. Todos are stored in localStorage (renderer process only)
2. Main process AI tools write todos but don't have access to localStorage
3. State can drift between what's in localStorage vs what AI thinks exists

### 6.2 Provider/Model Selector Non-Interactive (Issue #55)

**File:** `src/stores/providers.ts`

```typescript
setActiveProvider: (id) => {
  const provider = get().providers.find(p => p.id === id)
  if (provider) {
    set({
      activeProviderId: id,
      activeModel: provider.defaultModel,
    })
    // Async persistence without waiting
    window.jelico.providers.update(id, { defaultModel: provider.defaultModel })
      .catch((err) => {
        console.warn('[Providers] Failed to persist active provider:', err)
      })
  }
},
```

**Problem:** State is updated optimistically but persistence is async. Race conditions possible.

### 6.3 Context Window Inaccuracy (Issue #56)

**File:** `src/stores/context.ts`

```typescript
// Line 27
const FALLBACK_CONTEXT_SIZE = 100000

// Line 45
initConversationContext: async (conversationId, providerId, modelId) => {
  let modelContextSize = FALLBACK_CONTEXT_SIZE
  try {
    const size = await window.jelico.providers.getModelContextSize(providerId, modelId)
    if (size) {
      modelContextSize = size
    }
  } catch (err) {
    console.error('[Context] Error fetching context size:', err)
  }
}
```

**Problem:** 
1. Fallback is 100K but many local models support 256K+
2. No caching of model context sizes
3. No lookup order as suggested in issue (models.dev snapshot → live → API → fallback)

### 6.4 Editor Rendering Issues (Issue #54)

**File:** `src/components/Canvas/MonacoEditor.tsx` (not fully analyzed)

**Likely Causes:**
1. Monaco editor instance not properly disposed
2. CSS conflicts with parent container
3. Virtual scrolling issues with dynamic content

---

## 7. Recommendations

### Immediate (P0)

1. **Fix Permission System (Issue #57)**
   - Remove wildcard patterns
   - Implement exact-command matching
   - Add conversation-scoped permissions

2. **Fix XSS Vulnerabilities**
   - Sanitize SVG content before rendering
   - Use DOMPurify or similar library

### Short-term (P1)

3. **Refactor Chat Store**
   - Split into smaller stores
   - Extract streaming logic
   - Add proper TypeScript types

4. **Fix Todo State Drift (Issue #48)**
   - Move todo persistence to database (main process)
   - Add proper synchronization

5. **Improve Context Window Detection (Issue #56)**
   - Implement models.dev lookup
   - Add caching layer
   - Update fallback to 256K

### Medium-term (P2)

6. **Code Quality Improvements**
   - Add ESLint rules for `any` types
   - Implement proper error boundaries
   - Add unit tests for permission system

7. **Performance Optimizations**
   - Implement message pagination
   - Add virtual scrolling for long conversations
   - Optimize state updates during streaming

### Long-term

8. **Architecture Refactoring**
   - Extract tools into separate modules
   - Implement proper DAL (Data Access Layer)
   - Add service layer between IPC and database

---

## 8. Testing Recommendations

1. **Security Testing**
   - Test permission bypass scenarios
   - XSS payload testing in artifacts
   - Path traversal attempts in sandbox

2. **Integration Testing**
   - Sub-agent lifecycle testing
   - Provider switching scenarios
   - Context compaction edge cases

3. **Performance Testing**
   - Large conversation handling (10K+ messages)
   - Multiple concurrent sub-agents
   - Memory leak detection

---

## Appendix: File Structure Analysis

```
jelico/
├── electron/           # Main process
│   ├── ipc/           # IPC handlers (complexity concerns)
│   ├── services/      # Business logic
│   └── main.ts        # Entry point
├── src/               # Renderer process
│   ├── stores/        # Zustand stores (coupling issues)
│   ├── components/    # React components
│   └── lib/           # Utilities
└── package.json       # Dependencies
```

**Lines of Code (approximate):**
- TypeScript/TSX: ~15,000+ lines
- Main process: ~8,000 lines
- Renderer process: ~7,000 lines

---

*Report generated for Copilot CLI collaboration*
