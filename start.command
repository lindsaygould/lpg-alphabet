#!/bin/bash
set -e
cd "$(dirname "$0")"

echo "──────────────────────────────────────"
echo "  An alphabet by Laura Paresky Gould"
echo "──────────────────────────────────────"
echo ""

# If the server is already running, just open the browser.
if lsof -i :8765 -sTCP:LISTEN > /dev/null 2>&1; then
  echo "Server is already running on port 8765."
  echo "Opening browser..."
  open "http://localhost:8765"
  exit 0
fi

# Make npx available even when launched from Finder (no shell environment).
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if ! command -v npx > /dev/null 2>&1; then
  echo "npx not found. Install Node.js (https://nodejs.org) and try again."
  echo "Press any key to close this window."
  read -n 1 -s
  exit 1
fi

echo "Starting server on port 8765…"
echo "Opening browser shortly."
echo ""
echo "Leave this window open while you use the page."
echo "Close it (or press Ctrl+C) to stop the server."
echo ""

# Open the browser after a short delay so the server has time to bind.
( sleep 2 && open "http://localhost:8765" ) &

# Run the static server in the foreground so the Terminal window stays alive.
exec npx --yes http-server "." -p 8765 -c-1 --silent
