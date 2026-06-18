#!/bin/bash
# claude-agentrouter.sh

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SERVER_PATH="$SCRIPT_DIR/server.mjs"

echo -e "\033[0;36m🚀 Starting Agent Router Proxy in background...\033[0m"
node "$SERVER_PATH" > /dev/null 2>&1 &
PROXY_PID=$!

sleep 2

if ! kill -0 $PROXY_PID 2>/dev/null; then
  echo "Failed to start the proxy server." >&2
  exit 1
fi

export ANTHROPIC_BASE_URL="http://localhost:8083"
export ANTHROPIC_API_KEY="sk-agent-router-proxy"

echo -e "\033[0;32m🤖 Running Claude with Agent Router proxy...\033[0m"
claude "$@"

echo ""
echo -e "\033[0;36m🛑 Stopping Agent Router Proxy...\033[0m"
kill $PROXY_PID 2>/dev/null
