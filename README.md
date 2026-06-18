# Claude → Agent Router Proxy

A standalone local proxy that translates Anthropic API formats (used by the Claude Code CLI) into OpenAI-compatible API formats for Agent Router. Claude Code still talks to the local proxy with Anthropic variables; the proxy forwards requests to Agent Router using your token.

## Prerequisites
- [Node.js](https://nodejs.org/) (v18+ recommended)
- [Claude Code CLI](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview)

## Installation

1. Clone or download this repository.
2. Install the required dependencies:
   ```bash
   npm install
   ```

## Configuration

1. Copy the sample environment file and set up your variables:
   ```bash
   cp .env.sample .env
   ```
2. Open `.env` and add your **Agent Router API Key**:
   ```env
   AGENT_ROUTER_API_KEY=your_agent_router_api_key_here
   AGENT_ROUTER_BASE_URL=https://agentrouter.org/v1
   AGENT_ROUTER_MODEL=claude-sonnet-4-6
   ```

### Rate limiting

If your Agent Router plan has request limits, the proxy can keep Claude Code from hitting them during a burst of parallel tool calls. It applies a local sliding-window limiter before forwarding anything upstream:

- `AGENT_ROUTER_RPM_LIMIT` (default `40`) — max requests in any rolling 60s window
- `AGENT_ROUTER_RPM_MAX_WAIT_MS` (default `8000`) — how long a single Claude Code request will queue waiting for a slot before the proxy returns HTTP 429
- `AGENT_ROUTER_RPM_429_BACKOFF_MS` (default `15000`) — if Agent Router itself returns 429, the proxy pauses locally and rejects with 429 + `Retry-After` instead of piling more requests against a known-bad endpoint

When the limit is reached, additional requests **queue silently** up to `MAX_WAIT_MS` (visible in proxy logs as `[rl] queued N deep, wait=X.Xs`). Beyond that they get an immediate `429` so Claude Code can retry.

## Usage

There are two primary ways to run and use the proxy:

### Method 1: Standalone Proxy (Recommended for extensions & cowork)
If you want to leave the proxy running in the background so you can use Claude Code through IDE extensions, `claude cowork`, or multiple terminal windows:

1. Start the proxy server:
   ```powershell
   .\start.ps1
   # OR
   npm start
   ```
   *(The proxy will run on `http://localhost:8083`)*

2. Use Claude as you normally would in another terminal. The local `.clauderc.json` file ensures that Claude automatically routes its requests to the proxy when you are working inside this repository.

### Method 2: Wrapper Script
If you want a quick, isolated session, you can use the provided wrapper script. This script automatically starts the proxy, launches the Claude CLI, and safely shuts down the proxy when you exit Claude.

```powershell
.\claude-agentrouter.ps1
# OR
.\claude-agentrouter.cmd
```

## Global Claude Configuration
If you want to use this proxy globally across *all* of your projects (not just inside this directory), you can update your global Claude Code settings file located at `~/.claude/settings.json` (or `%USERPROFILE%\.claude\settings.json` on Windows):

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "http://localhost:8083",
    "ANTHROPIC_API_KEY": "sk-agent-router-proxy",
    "ANTHROPIC_MODEL": "claude-sonnet-4-6"
  }
}
```
*(When configured globally, make sure to use **Method 1** to keep the proxy running in the background).*
