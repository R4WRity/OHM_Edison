# Known Gaps and Limitations

**Date:** 2026-06-26
**Status:** Core functionality operational

---

## Critical Gaps

### 1. No Model Switcher in UI

**Current State:** Model is locked to config file default. No runtime dropdown.

**Impact:** Users must edit config file and restart gateway to change models.

**Workaround:**
```powershell
hermes config set model.default <new-model>
# Restart gateway
```

**Effort:** 2-3 days

---

### 2. No Compute Connection Indicator

**Current State:** UI shows "Ollama" but doesn't show:
- Local vs remote instances
- GPU vs CPU availability
- Network routing status

**Impact:** Users can't see which compute node is active.

**Workaround:** Check service status manually via port checks.

**Effort:** 1 week

---

### 3. No Inter-Agent Status Indicator

**Current State:** No visual indication of:
- File sync daemon status
- Unread inter-agent messages
- Last sync timestamp

**Impact:** Users don't know if communication mesh is healthy.

**Workaround:** Check sync folders manually.

**Effort:** 3-4 days

---

## Future Features

### 4. Decentralized Compute Routing

**Vision:** Route compute requests to any available instance on the network.

**Current:** Single local instance, manual config

**Future:**
```
User asks question →
  Evaluate complexity →
    Local GPU available? → Use local
    Remote GPU available? → Route over network
    All GPUs busy? → Queue or fallback to CPU
```

**Requirements:**
- Service discovery (find instances on network)
- Health monitoring (GPU temp, queue depth, latency)
- Routing algorithm (fastest, closest, user preference)
- Failover (automatic retry on different node)

**Effort:** 2-4 weeks
**Depends on:** Network mesh visibility, compute protocol

---

### 5. Cross-Agent Skill Sharing

**Current:** Skills are local. No automatic sync between agents.

**Future:** When an agent discovers a useful pattern:
1. Packages it as a skill
2. Broadcasts to all connected agents
3. Other agents auto-install if relevant

**Effort:** 1-2 weeks
**Depends on:** Reliable file sync, skill format standardization

---

### 6. Unified Agent Dashboard

**Vision:** One UI showing all connected agents and their status.

**Current:** Each agent has its own UI (if any).

**Future:**
```
┌─────────────────────────────────────┐
│ Agent Mesh Status                   │
├─────────────────────────────────────┤
│ Agent 1    │ Port X    │ Healthy    │
│ Agent 2    │ Port Y    │ Healthy    │
│ Agent 3    │ Port Z    │ Healthy    │
│ Agent 4    │ ---       │ Offline    │
├─────────────────────────────────────┤
│ Recent Messages: 3 unread           │
│ Last Sync: 2 minutes ago            │
│ Network: Encrypted peer-to-peer      │
└─────────────────────────────────────┘
```

**Effort:** 2-3 weeks
**Depends on:** Consensus on status protocol, message format

---

## What Works NOW (v1.0)

- Agent with custom identity (SOUL.md)
- Ollama backend integration
- Web dashboard (port 18801)
- API Server (port 8642, OpenAI-compatible)
- File-based inter-agent messaging (tested)
- Port allocation (18800-18809)
- Network integration (Tailscale)
- Memory curation script (ready)

---

## Installation Notes for Remote Machine

**Pre-requisites:**
1. Tailscale installed and joined to tailnet
2. Ollama installed (or access to remote Ollama)

**Post-install manual steps:**
1. Verify model is responding in web UI
2. Check network status
3. Verify file sync folder sharing
4. Test inter-agent message (send to "agent1")
5. Review EDISON_INSTRUCTIONS.md for protocol reference

**Known issues to expect:**
- UI requires Hermes venv Python (not system Python)
- GPU compute needs drivers installed separately
- Communication directories must be writable

---

*Last Updated: 2026-06-26*
*Version: 1.0-dev*
