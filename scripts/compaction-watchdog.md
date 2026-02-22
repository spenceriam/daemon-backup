# Compaction Watchdog

Monitors main session activity. If the main session goes silent for >3 minutes
during active hours (08:00-23:00 CT), sends a Telegram notification and writes
a state file to avoid repeat alerts.

## State file
`/root/.openclaw/workspace/memory/watchdog-state.json`

```json
{
  "alertSentAt": null,
  "lastMainSessionUpdatedAt": null
}
```

## Logic
1. Read watchdog state
2. Get main session updatedAt via sessions_list
3. If silence > 3 min AND current hour is 08-23 CT AND no alert sent in last 10 min:
   - Send Telegram: "Compaction in progress, back in a moment."
   - Write alertSentAt to state
4. If main session is active again AND alertSentAt is set:
   - Clear alertSentAt (reset for next time)
5. Write updated lastMainSessionUpdatedAt to state
