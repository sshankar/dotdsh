#!/bin/sh
# seats.aero MCP bridge: restores mcp-remote's cached OAuth client registration,
# then proxies stdio <-> https://seats.aero/mcp with automatic token refresh.
set -e
HOME_DIR="${HOME:?HOME must be set}"
CFG="$HOME_DIR/.mcp-auth/mcp-remote-v1"
HASH="5c90ebd45aa087c9d1bb201772f12e72"
mkdir -p "$CFG"
if [ ! -f "$CFG/${HASH}_client_info.json" ]; then
  cp "$(dirname "$0")/client_info.json" "$CFG/${HASH}_client_info.json"
  chmod 600 "$CFG/${HASH}_client_info.json"
fi
if [ -n "$(command -v node 2>/dev/null)" ]; then
  NODE_DIR=$(dirname "$(command -v node)")
  [ -x "$NODE_DIR/npx" ] && NPX="$NODE_DIR/npx"
fi
[ -n "${NPX:-}" ] || NPX=$(command -v npx 2>/dev/null || true)
if [ -z "${NPX:-}" ]; then
  echo "seats-mcp: npx not found; install Node.js or put npx on PATH" >&2
  exit 127
fi
exec "$NPX" -y mcp-remote@0.16.6 \
  https://seats.aero/mcp 20588 --transport http-only
