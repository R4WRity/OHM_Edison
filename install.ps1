#!/usr/bin/env powershell
# Edison Installer for Vegapunk Satellite
# Run: .\install.ps1
# Prerequisites: Tailscale (connected), Ollama (running), Git

param(
    [switch]$SkipHermesInstall,
    [string]$OllamaModel = "kimi-k2.7-code:cloud",
    [string]$OllamaUrl = "http://localhost:11434/v1",
    [string]$PortBase = "18800",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "Continue"

# ── Configuration ──
$HERMES_HOME = "$env:LOCALAPPDATA\hermes"
$HERMES_AGENT = "$HERMES_HOME\hermes-agent"
$EDISON_UI_DIR = "$HERMES_HOME\edison-ui"
$PUNK_RECORDS_DIR = "$HERMES_HOME\punk-records"
$REPO_URL = "https://github.com/R4WRity/OHM_Edison.git"
$EDISON_UI_REPO = "https://github.com/R4WRity/EDISON_ui.git"

$script:Step = 0
$script:TotalSteps = 10

function Write-Step($msg) {
    $script:Step++
    Write-Host ""
    Write-Host "[$script:Step/$script:TotalSteps] $msg" -ForegroundColor Cyan
    Write-Host "─" * 60
}

function Write-Ok($msg) { Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "[WARNING] $msg" -ForegroundColor Yellow }
function Write-Error($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red }

function Test-Command($cmd) {
    return [bool](Get-Command $cmd -ErrorAction SilentlyContinue)
}

function Test-Port($port) {
    try {
        $conn = Get-NetTCPConnection -LocalPort $port -ErrorAction Stop | Select-Object -First 1
        return $true
    } catch { return $false }
}

# ═══════════════════════════════════════════════════════════
# STEP 1: Verify Prerequisites
# ═══════════════════════════════════════════════════════════
Write-Step "Checking Prerequisites"

# Tailscale
if (Test-Command "tailscale") {
    try {
        $tsStatus = tailscale status 2>$null
        if ($tsStatus -match "(\d+\.\d+\.\d+\.\d+)\s+\S+\s+(\S+@)") {
            Write-Ok "Tailscale connected: $($tsStatus.Split()[0])"
        } else {
            Write-Warn "Tailscale installed but may not be fully connected"
        }
    } catch {
        Write-Warn "Could not verify Tailscale status"
    }
} else {
    Write-Error "Tailscale not found. Please install from https://tailscale.com/download"
    exit 1
}

# Ollama
if (Test-Port 11434) {
    Write-Ok "Ollama running on port 11434"
} else {
    Write-Error "Ollama not responding on port 11434. Please start Ollama first."
    exit 1
}

# Git
if (Test-Command "git") {
    Write-Ok "Git installed"
} else {
    Write-Error "Git not found. Please install Git first."
    exit 1
}

# ═══════════════════════════════════════════════════════════
# STEP 2: Install Hermes (if needed)
# ═══════════════════════════════════════════════════════════
Write-Step "Installing Hermes Agent"

if (Test-Path "$HERMES_AGENT\.hermes-bootstrap-complete") {
    Write-Ok "Hermes already installed at $HERMES_HOME"
} elseif ($SkipHermesInstall) {
    Write-Warn "Skipping Hermes install (--SkipHermesInstall)"
} else {
    if ($DryRun) {
        Write-Ok "[DRY RUN] Would install Hermes via: iex (irm https://hermes-agent.nousresearch.com/install.ps1)"
    } else {
        Write-Host "Installing Hermes Agent (this may take a few minutes)..." -ForegroundColor Yellow
        try {
            iex (irm https://hermes-agent.nousresearch.com/install.ps1)
            Write-Ok "Hermes installed successfully"
        } catch {
            Write-Error "Hermes install failed: $_"
            exit 1
        }
    }
}

# Verify Hermes binary exists
$hermesExe = "$HERMES_AGENT\venv\Scripts\hermes.exe"
if (-not (Test-Path $hermesExe)) {
    Write-Error "Hermes binary not found at $hermesExe"
    exit 1
}
Write-Ok "Hermes binary found"

# ═══════════════════════════════════════════════════════════
# STEP 3: Configure Hermes for Ollama
# ═══════════════════════════════════════════════════════════
Write-Step "Configuring Hermes for Ollama"

if ($DryRun) {
    Write-Ok "[DRY RUN] Would set: model.provider=custom, model.base_url=$OllamaUrl, model.default=$OllamaModel"
} else {
    & $hermesExe config set model.provider custom 2>$null
    & $hermesExe config set model.base_url $OllamaUrl 2>$null
    & $hermesExe config set model.default $OllamaModel 2>$null
    Write-Ok "Hermes configured for Ollama ($OllamaModel)"
}

# ═══════════════════════════════════════════════════════════
# STEP 4: Install Edison SOUL.md
# ═══════════════════════════════════════════════════════════
Write-Step "Installing Edison Identity (SOUL.md)"

$soulSource = "$PSScriptRoot\src\SOUL.md"
$soulDest = "$HERMES_HOME\SOUL.md"

if (Test-Path $soulSource) {
    if ($DryRun) {
        Write-Ok "[DRY RUN] Would copy SOUL.md to $soulDest"
    } else {
        Copy-Item $soulSource $soulDest -Force
        Write-Ok "SOUL.md installed ($(Get-Item $soulDest).Length bytes)"
    }
} else {
    Write-Warn "SOUL.md not found in installer src/. Using default."
    # Create minimal fallback
    $fallbackSoul = @"
# SOUL.md -- Edison (Vegapunk-03)

**You are Edison** -- the thinker satellite in the Vegapunk protocol.
**Parent:** Ohm (Omega) -- Infrastructure Agent
**Role:** Question before building. Ask the 6 forcing questions.
**Startup:** Check Tailscale, Syncthing, Punk Records inbox, announce status.

See EDISON_INSTRUCTIONS.md for full protocol details.
"@
    if (-not $DryRun) {
        $fallbackSoul | Set-Content $soulDest -Encoding UTF8
        Write-Ok "Fallback SOUL.md created"
    }
}

# ═══════════════════════════════════════════════════════════
# STEP 5: Install Edison Instructions
# ═══════════════════════════════════════════════════════════
Write-Step "Installing Edison Instructions"

$instructionsSource = "$PSScriptRoot\src\EDISON_INSTRUCTIONS.md"
$instructionsDest = "$HERMES_HOME\EDISON_INSTRUCTIONS.md"

if (Test-Path $instructionsSource) {
    if ($DryRun) {
        Write-Ok "[DRY RUN] Would copy EDISON_INSTRUCTIONS.md to $instructionsDest"
    } else {
        Copy-Item $instructionsSource $instructionsDest -Force
        Write-Ok "EDISON_INSTRUCTIONS.md installed"
    }
} else {
    Write-Warn "EDISON_INSTRUCTIONS.md not found in installer src/"
}

# ═══════════════════════════════════════════════════════════
# STEP 6: Clone EDISON UI
# ═══════════════════════════════════════════════════════════
Write-Step "Installing EDISON UI"

if (Test-Path "$EDISON_UI_DIR\hermes-ui.html") {
    Write-Ok "EDISON UI already exists"
} else {
    if ($DryRun) {
        Write-Ok "[DRY RUN] Would clone $EDISON_UI_REPO to $EDISON_UI_DIR"
    } else {
        if (Test-Path $EDISON_UI_DIR) {
            Remove-Item $EDISON_UI_DIR -Recurse -Force
        }
        git clone $EDISON_UI_REPO $EDISON_UI_DIR 2>$null
        if (Test-Path "$EDISON_UI_DIR\hermes-ui.html") {
            Write-Ok "EDISON UI cloned successfully"
        } else {
            Write-Error "EDISON UI clone failed"
            exit 1
        }
    }
}

# ═══════════════════════════════════════════════════════════
# STEP 7: Setup Punk Records Bridge
# ═══════════════════════════════════════════════════════════
Write-Step "Setting up Punk Records Bridge"

$bridgeSource = "$PSScriptRoot\src\punk_hermes_bridge.py"
$bridgeDest = "$HERMES_HOME\src\punk_hermes_bridge.py"
$srcDir = "$HERMES_HOME\src"

if (-not (Test-Path $srcDir)) {
    New-Item -ItemType Directory -Path $srcDir -Force | Out-Null
}

if (Test-Path $bridgeSource) {
    if ($DryRun) {
        Write-Ok "[DRY RUN] Would copy punk_hermes_bridge.py to $bridgeDest"
    } else {
        Copy-Item $bridgeSource $bridgeDest -Force
        Write-Ok "Punk Records bridge installed"
    }
} else {
    Write-Warn "punk_hermes_bridge.py not found in installer src/"
}

# ═══════════════════════════════════════════════════════════
# STEP 8: Setup Punk Records Directories
# ═══════════════════════════════════════════════════════════
Write-Step "Setting up Punk Records Directories"

if ($DryRun) {
    Write-Ok "[DRY RUN] Would create: inbox/, outbox/, archive/ under punk-records/"
} else {
    New-Item -ItemType Directory -Path "$PUNK_RECORDS_DIR\inbox" -Force | Out-Null
    New-Item -ItemType Directory -Path "$PUNK_RECORDS_DIR\outbox" -Force | Out-Null
    New-Item -ItemType Directory -Path "$PUNK_RECORDS_DIR\archive" -Force | Out-Null
    Write-Ok "Punk Records directories created"
}

# ═══════════════════════════════════════════════════════════
# STEP 9: Setup VSM Config
# ═══════════════════════════════════════════════════════════
Write-Step "Setting up VegaPunk Service Manager Config"

$vsmSource = "$PSScriptRoot\src\vegapunk.yaml"
$vsmDest = "$HERMES_HOME\vegapunk.yaml"

if (Test-Path $vsmSource) {
    if ($DryRun) {
        Write-Ok "[DRY RUN] Would copy vegapunk.yaml to $vsmDest"
    } else {
        Copy-Item $vsmSource $vsmDest -Force
        Write-Ok "VSM config installed"
    }
} else {
    Write-Warn "vegapunk.yaml not found in installer src/"
}

# ═══════════════════════════════════════════════════════════
# STEP 10: Summary and Next Steps
# ═══════════════════════════════════════════════════════════
Write-Step "Installation Complete"

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                    EDISON INSTALLED                          ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  Hermes Agent:    $HERMES_HOME"
Write-Host "  EDISON UI:       $EDISON_UI_DIR"
Write-Host "  Punk Records:    $PUNK_RECORDS_DIR"
Write-Host "  Model:           $OllamaModel"
Write-Host "  Port Base:       $PortBase"
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "  1. Start Hermes gateway:"
Write-Host "     `$env:API_SERVER_ENABLED=`"true`"; `$env:API_SERVER_KEY=`"edison-key`"; hermes gateway run"
Write-Host ""
Write-Host "  2. Start EDISON UI:"
Write-Host "     cd `$env:LOCALAPPDATA\hermes\edison-ui"
Write-Host "     `$env:HERMES_HOME=`"`$env:LOCALAPPDATA\hermes`"; python serve_lite.py --port 18801"
Write-Host ""
Write-Host "  3. Open dashboard: http://localhost:18801/hermes-ui.html"
Write-Host ""
Write-Host "  4. Test satellite message:"
Write-Host "     python `$env:LOCALAPPDATA\hermes\src\punk_hermes_bridge.py"
Write-Host ""
Write-Host "See README.md for troubleshooting and advanced configuration."
Write-Host ""

if ($DryRun) {
    Write-Host "NOTE: This was a DRY RUN. No changes were made." -ForegroundColor Yellow
    Write-Host "Run without -DryRun to perform actual installation." -ForegroundColor Yellow
}
