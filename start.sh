#!/bin/bash
# start.sh
# Starts the global Anthropic → Agent Router Proxy (Node.js)

echo -e "\033[0;36m=== Agent Router Proxy ===\033[0m"
echo -e "\033[0;32mPort  : 8083\033[0m"
echo -e "\033[0;32mModel : claude-sonnet-4-6\033[0m"
echo ""
echo -e "\033[0;33mStarting proxy... (Ctrl+C to stop)\033[0m"
echo ""

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SERVER_PATH="$SCRIPT_DIR/server.mjs"
LOG_DIR="$SCRIPT_DIR/logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
LOG_PATH="$LOG_DIR/proxy_$TIMESTAMP.log"

echo -e "\033[0;37mProxy logs will be saved to: $LOG_PATH\033[0m"

node "$SERVER_PATH" 2>&1 | tee -a "$LOG_PATH"
