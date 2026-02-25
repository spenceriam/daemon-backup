# OpenClaw Security Configuration

## Current Settings

### Version
- OpenClaw: [check with `openclaw --version`]

### Tool Access Control
- Review `gateway.nodes.denyCommands` in openclaw.json
- Keep Control UI local-only (bind: loopback)

### Recommendations
1. Fix denyCommands configuration if needed
2. Pin plugin versions for supply-chain security
3. Review tool policies if handling untrusted input

---
Last updated: 2026-02-22
