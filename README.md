# Edison — Satellite Agent Installer

**One-command installer for Edison, a Hermes-based AI satellite agent.**

Edison is an AI agent built on the Hermes framework with satellite mesh communication capabilities.

## Prerequisites

Before running the installer, you must have:

1. **Tailscale** — Installed and connected to your tailnet
   ```powershell
   # Download from https://tailscale.com/download
   # Sign in with your Tailscale account
   tailscale status  # Verify connection
   ```

2. **Ollama** — Installed and running
   ```powershell
   # Download from https://ollama.com/download
   # Start Ollama (runs in background)
   ollama pull your-preferred-model
   ```

3. **Git** — For cloning the UI
   ```powershell
   git --version  # Verify installed
   ```

## Quick Install

Open PowerShell as Administrator and run:

```powershell
iex (irm https://raw.githubusercontent.com/R4WRity/OHM_Edison/main/install.ps1)
```

Or clone and run locally:

```powershell
git clone https://github.com/R4WRity/OHM_Edison.git
cd OHM_Edison
.\install.ps1
```

## What Gets Installed

| Component | Location | Purpose |
|-----------|----------|---------|
| Hermes Agent | `%LOCALAPPDATA%\hermes\` | Core AI agent framework |
| Edison SOUL | `%LOCALAPPDATA%\hermes\SOUL.md` | Agent identity & protocol knowledge |
| Edison Instructions | `%LOCALAPPDATA%\hermes\EDISON_INSTRUCTIONS.md` | Protocol reference |
| Web UI | `%LOCALAPPDATA%\hermes\edison-ui\` | Web dashboard |
| Satellite Bridge | `%LOCALAPPDATA%\hermes\src\punk_hermes_bridge.py` | Inter-agent communication |
| Service Config | `%LOCALAPPDATA%\hermes\vegapunk.yaml` | Service orchestration |

## Post-Install

After installation completes:

1. **Access the dashboard:**
   ```
   http://localhost:18801
   ```

2. **Start services manually (if needed):**
   ```powershell
   # Hermes gateway (API server)
   hermes gateway run
   
   # Web UI
   cd %LOCALAPPDATA%\hermes\edison-ui
   python serve_lite.py --port 18801
   ```

## Port Allocation

| Port | Service |
|------|---------|
| 18800 | Gateway (API Server) |
| 18801 | Web Dashboard |
| 18802 | Voice Interface (future) |
| 18803 | Neo4j HTTP |
| 18804 | Neo4j Bolt |
| 18805 | Service Manager |
| 18806 | Monitoring |
| 18807 | Satellite Bridge |
| 18808-18809 | Reserved |

## Troubleshooting

### "No messaging platforms enabled"
Edison uses API-only mode. This warning is expected and can be ignored.

### "Cannot import AIAgent"
Use Hermes venv Python, not system Python:
```powershell
%LOCALAPPDATA%\hermes\hermes-agent\venv\Scripts\python.exe serve_lite.py
```

### Ollama not responding
Verify Ollama is running:
```powershell
Invoke-RestMethod -Uri "http://localhost:11434/api/tags"
```

### Satellite communication not syncing
Verify Syncthing is running and folders are shared:
```powershell
# Syncthing web UI
http://localhost:8384
```

## Gaps and Limitations

See [GAPS.md](GAPS.md) for known limitations and future roadmap.

## Support

- **GitHub Issues:** https://github.com/R4WRity/OHM_Edison/issues

---

**Protocol: Satellite Mesh v1**
