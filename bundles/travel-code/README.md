# travel-code bundle

Adds one agent preset, **Travel (code)**: the shipped `ptc` composition plus MCP
servers for travel planning. Today that is seats.aero (award search, live search,
alerts); add further servers as extra `mcp-*` rows with unique `serverName`s.

The source of truth lives here, in `~/.dsh/bundles/travel-code`. The profile gets an
installed copy (no symlink) from the packed tarball next to this directory.

## Why a bridge

seats.aero's MCP server (`https://seats.aero/mcp`) serves 8 tools anonymously and
~42 tools — `live_search`, `find_deals`, `create_alert`, hotel/fare-class alerts,
upgrade space — only with an OAuth token. DSH's MCP client speaks stdio and
streamable HTTP with static headers but has no OAuth flow, so `mcp-remote` bridges
stdio to the remote server and owns the OAuth dance (DCR + PKCE S256, 10-minute
access tokens, rotating refresh tokens).

## Auth state

Tokens live in `~/.mcp-auth/mcp-remote-v1/` (mode 600), keyed by
`md5("https://seats.aero/mcp")` = `5c90ebd45aa087c9d1bb201772f12e72`:

- `5c90…_tokens.json` — access + refresh token, scope, issuer
- `5c90…_client_info.json` — the dynamic client registration

The callback port is pinned to **20588** because the registered client
(`dcr-3MDBDQJV3tB87LPomO8KB50Vdm4`) has `http://localhost:20588/oauth/callback`
as its redirect. Changing the port requires re-registering the client.

`bin/seats-mcp.sh` restores `client_info.json` from `bin/client_info.json` if
mcp-remote deletes it. That matters: seats.aero rate-limits dynamic client
registration to roughly one per hour per IP, so a missing registration followed by
a re-register fails with HTTP 429.

## Re-authenticate

If seats.aero revokes the connection (seats.aero → MCP connections) or the refresh
token is rejected:

```sh
rm ~/.mcp-auth/mcp-remote-v1/5c90ebd45aa087c9d1bb201772f12e72_tokens.json
~/.dsh/bundles/travel-code/bin/seats-mcp.sh   # opens the browser; approve, then Ctrl-C
```

Then start a new session with the preset.

## Verify

```sh
{ printf '%s\n' \
  '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"verify","version":"0"}}}' \
  '{"jsonrpc":"2.0","method":"notifications/initialized"}' \
  '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}'; sleep 10; } \
| ~/.dsh/bundles/travel-code/bin/seats-mcp.sh 2>/dev/null
```

A healthy session answers with 42 tools; anonymous access answers with 8.

## Add another MCP server

Append a row next to `mcp-seats` in `cordis.patch.yml`:

```yaml
          - id: mcp-hotels
            name: '@deepseek-ai/dsh-mcp-client'
            config:
              serverName: hotels
              transport: streamable-http
              url: https://example.com/mcp
```

Bump `version` in `package.json`, repack, and reinstall:

```sh
cd ~/.dsh/bundles/travel-code
npm pack --pack-destination ~/.dsh/bundles
```

Then `plugin_manager` → `remove_bundle @local/dsh-travel-code` → `install_bundle`
with the new `.tgz`.

## Maintenance

- The preset's plugin list is copied from
  `dsh-web-app/presets/ptc.patch.yml`. Re-copy it when upgrading DSH.
- Tools appear as `mcp__<serverName>__<tool>` and are only callable inside
  `run_code` while this preset is selected.
- Remove with `plugin_manager` → `remove_bundle @local/dsh-travel-code`.
