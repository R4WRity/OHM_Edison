# Edison — Vegapunk Satellite Installer

**One-command installer for Edison, the Vegapunk satellite agent.**

Edison is a Hermes-based AI agent configured for the Vegapunk protocol — a federated satellite mesh with decentralized memory, cross-agent communication, and distributed compute.

## Prerequisites

Before running the installer, you must have:

1. **Tailscale** — Installed and connected to the tailnet
   ```powershell
   # Download from https://tailscale.com/download
   # Sign in with your Tailscale account
   tailscale status  # Verify connection
   ```

2. **Ollama** — Installed and running
   ```powershell
   # Download from https://ollama.com/download
   # Start Ollama (runs in background)
   ollama pull kimi-k2.7-code:cloud  # Or your preferred model
   ```

3. **Git** — For cloning the Edison UI
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
| Edison SOUL | `%LOCALAPPDATA%\hermes\SOUL.md` | Satellite identity & protocol |
| Edison Instructions | `%LOCALAPPDATA%\hermes\EDISON_INSTRUCTIONS.md` | Framework reference |
| EDISON UI | `%LOCALAPPDATA%\hermes\edison-ui\` | Web dashboard (port 18801) |
| Punk Records Bridge | `%LOCALAPPDATA%\hermes\src\punk_hermes_bridge.py` | Satellite communication |
| VSM Config | `%LOCALAPPDATA%\hermes\vegapunk.yaml` | Service orchestration |

## Post-Install

After installation completes:

1. **Access the dashboard:**
   ```
   http://localhost:18801/hermes-ui.html
   ```

2. **Verify satellite connectivity:**
   ```powershell
   cd %LOCALAPPDATA%\hermes\src
   python punk_hermes_bridge.py
   ```

3. **Check Punk Records inbox:**
   ```powershell
   # Messages from other satellites appear here:
   %LOCALAPPDATA%\hermes\punk-records\inbox\
   ```

4. **Start services manually (if needed):**
   ```powershell
   # Hermes gateway (API server)
   hermes gateway run
   
   # EDISON UI
   cd %LOCALAPPDATA%\hermes\edison-ui
   python serve_lite.py --port 18801
   ```

## Architecture

```
User → EDISON UI (port 18801) → Hermes API (port 8642) → Ollama (port 11434)
                                   ↓
                            Punk Records Bridge → Syncthing → Satellite Mesh
                                   ↓
                            Local Neo4j KG (port 18803)
```

## Port Allocation

| Port | Service |
|------|---------|
| 18800 | Gateway (Hermes API Server) |
| 18801 | EDISON UI (Web Dashboard) |
| 18802 | Voice Interface (future) |
| 18803 | Neo4j HTTP |
| 18804 | Neo4j Bolt |
| 18805 | VSM (VegaPunk Service Manager) |
| 18806 | Control Tower |
| 18807 | Punk Records Local Bridge |
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
curl http://localhost:11434/api/tags
```

### Punk Records not syncing
Verify Syncthing is running and folders are shared:
```powershell
# Syncthing web UI
http://localhost:8384
```

## Gaps and Limitations

See [GAPS.md](GAPS.md) for known limitations and future roadmap.

## Support

- **Discord:** Ohm's Den — #sigma-chat
- **Punk Records:** Send status message to "ohm" satellite
- **GitHub Issues:** https://github.com/R4WRity/OHM_Edison/issues

---

**Vegapunk Protocol v1 | Project Prometheus**
