# Edison v1.0 — Known Gaps and Limitations

**Date:** 2026-06-26
**Status:** Ready for remote install despite gaps
**Priority:** Core functionality works, gaps are UI/convenience features

---

## Critical Gaps (Affect User Experience)

### 1. No Model Switcher in EDISON UI

**Current State:** Model is locked to `config.yaml` default. No runtime dropdown.

**Impact:** Users must edit config file and restart gateway to change models.

**Workaround:**
```powershell
hermes config set model.default <new-model>
# Restart gateway
```

**Fix Needed:**
- Add dropdown to EDISON UI settings panel
- Backend endpoint in serve_lite.py to rewrite config.yaml
- Gateway restart logic

**Effort:** 2-3 days

---

### 2. No llamactl Connection Indicator

**Current State:** UI shows "Ollama" but doesn't distinguish between:
- Local Ollama (port 11434)
- llamactl (port 8080) with GPU routing
- Remote instances via Tailscale

**Impact:** Users can't see which compute node is active or whether decentralized compute is available.

**Workaround:** Check `vsm.py status` or query ports manually.

**Fix Needed:**
- Health check endpoint for llamactl instances
- UI panel showing compute nodes and their status
- Auto-failover logic

**Effort:** 1 week

---

### 3. No Punk Records Status Indicator

**Current State:** No visual indication in EDISON UI of:
- Whether Punk Records daemon is running
- Whether Syncthing is syncing
- Number of unread satellite messages
- Last sync timestamp

**Impact:** Users don't know if satellite mesh is healthy.

**Workaround:** Check files in `punk-records/inbox/` manually.

**Fix Needed:**
- Status bar widget in EDISON UI
- Polling endpoint for inbox/outbox stats
- Notification badge for unread messages

**Effort:** 3-4 days

---

## Future Features (Post-v1.0)

### 4. Decentralized Compute Mesh

**Vision:** Route compute requests to any llama CPP instance on the network.

**Current:** Single Ollama instance, manual config

**Future:**
```
User asks question →
  Edison evaluates complexity →
    Local GPU available? → Use local
    Remote GPU available? → Route via Tailscale
    All GPUs busy? → Queue or fallback to CPU
```

**Requirements:**
- Service discovery (find llama CPP instances on tailnet)
- Health monitoring (GPU temp, queue depth, latency)
- Routing algorithm (fastest, closest, user preference)
- Failover (automatic retry on different node)

**Effort:** 2-4 weeks
**Depends on:** Tailscale mesh visibility, llamactl network protocol

---

### 5. Cross-Satellite Skill Broadcasting

**Current:** Skills are local. No automatic sync between satellites.

**Future:** When Edison discovers a useful pattern:
1. Packages it as a skill
2. Broadcasts via Punk Records to all satellites
3. Other satellites auto-install if relevant

**Effort:** 1-2 weeks
**Depends on:** Punk Records reliability, skill format standardization

---

### 6. Unified Satellite Dashboard

**Vision:** One UI showing all satellites and their status.

**Current:** Each satellite has its own UI (if any).

**Future:**
```
┌─────────────────────────────────────┐
│ Vegapunk Satellite Mesh Status      │
├─────────────────────────────────────┤
│ 🟢 Ohm        │ Port 9300 │ Healthy │
│ 🟢 Core       │ Port 9301 │ Healthy │
│ 🟢 Edison     │ Port 18800│ Healthy │
│ ⚪ Future-sat │ ---       │ Offline │
├─────────────────────────────────────┤
│ Recent Messages: 3 unread           │
│ Last Sync: 2 minutes ago            │
│ Network: Tailscale (encrypted)       │
└─────────────────────────────────────┘
```

**Effort:** 2-3 weeks
**Depends on:** Consensus on status protocol, Punk Records message format

---

## What Works NOW (v1.0)

✅ Hermes Agent with Edison SOUL (identity + protocol knowledge)
✅ Ollama backend (kimi-k2.7-code:cloud)
✅ EDISON UI web dashboard (port 18801)
✅ API Server (port 8642, OpenAI-compatible)
✅ Punk Records file-based messaging (tested)
✅ Port allocation (18800-18809)
✅ Tailscale integration
✅ Memory curation script (ready)

---

## Installation Notes for Remote Machine

**Pre-requisites:**
1. Tailscale installed and joined to tailnet
2. Ollama installed (or access to remote Ollama)

**Post-install manual steps:**
1. Verify model is responding in EDISON UI
2. Check Tailscale status
3. Verify Syncthing folder sharing for Punk Records
4. Test satellite message (send to "ohm")
5. Review EDISON_INSTRUCTIONS.md for protocol reference

**Known issues to expect:**
- EDISON UI requires Hermes venv Python (not system Python)
- llamactl needs GPU drivers installed separately
- Punk Records directories must be writable

---

*Last Updated: 2026-06-26*
*Edison Version: 1.0-dev*
*Protocol: Vegapunk v1*
