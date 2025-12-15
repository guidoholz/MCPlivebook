# Livebook Docker with MCP Server

A Docker setup for running [Livebook](https://livebook.dev/) with [livebook_tools](https://github.com/thmsmlr/livebook_tools) MCP server integration. This enables AI assistants like Claude Code and Cursor to interact with Livebook notebooks in real-time.

## What it does

- Runs Livebook in a Docker container
- Automatically syncs file changes to open Livebook sessions
- Provides an MCP (Model Context Protocol) server for AI assistant integration
- Auto-watches notebooks when opened in Livebook

## Components

- **Docker** - Containerized Livebook environment
- **Livebook** - Interactive Elixir notebooks
- **livebook_tools** - MCP server and file watcher (cloned from GitHub during build)
- **Elixir 1.18 / OTP 27** - Runtime environment

## Quick Start

### 1. Clone and Start

```bash
git clone <this-repo>
cd livebook-docker

# Build and start the container
docker compose up -d --build
```

Livebook will be available at http://localhost:8080

### 2. Create Notebooks

Place your `.livemd` files in the `notebooks/` directory. They will be available inside the container at `/data/notebooks/`.

### 3. Auto-Watcher

When you open a notebook in Livebook (via browser), the auto-watcher automatically connects and syncs file changes. Any edits made to the `.livemd` files will be reflected in Livebook in real-time.

## MCP Server Setup

The MCP server allows AI assistants to interact with your Livebook sessions.

### Claude Code

Add the MCP server to Claude Code:

```bash
claude mcp add livebook_docker /path/to/livebook-docker/scripts/mcp-docker.sh
```

Or add manually to your Claude settings (`~/.claude/settings.json`):

```json
{
  "mcpServers": {
    "livebook_docker": {
      "command": "/path/to/livebook-docker/scripts/mcp-docker.sh",
      "args": []
    }
  }
}
```

Restart Claude Code after adding the MCP server.

### Cursor

Add to your Cursor MCP settings (`.cursor/mcp.json` or global settings):

```json
{
  "mcpServers": {
    "livebook_docker": {
      "command": "/path/to/livebook-docker/scripts/mcp-docker.sh",
      "args": []
    }
  }
}
```

## Configuration

### Environment Variables

Configure in `docker-compose.yml`:

| Variable | Default | Description |
|----------|---------|-------------|
| `LIVEBOOK_PORT` | `8080` | Web interface port |
| `LIVEBOOK_TOKEN_ENABLED` | `false` | Authentication token |
| `LIVEBOOK_NODE` | `livebook@127.0.0.1` | Erlang node name |
| `LIVEBOOK_COOKIE` | `secret` | Erlang distribution cookie |
| `LIVEBOOK_AUTOSAVE_PATH` | `none` | Disable autosave to prevent conflicts |

### Ports

- `8080` - Livebook web interface

### Volumes

- `./notebooks:/data/notebooks` - Your notebook files

## Files

```
.
├── Dockerfile              # Docker image definition
├── docker-compose.yml      # Container orchestration
├── scripts/
│   ├── docker-entrypoint.sh    # Container startup script
│   ├── watch-all.sh            # Auto-watcher for notebooks
│   ├── mcp-docker.sh           # MCP server wrapper script
│   └── watch-docker.sh         # Manual watcher script
└── notebooks/              # Your .livemd files
```

## Usage

### Starting the Container

```bash
docker compose up -d
```

### Stopping the Container

```bash
docker compose down
```

### Rebuilding from Scratch

```bash
docker compose down --rmi all
docker compose up -d --build
```

### Viewing Logs

```bash
docker compose logs -f
```

### Opening a Notebook

```bash
open "http://localhost:8080/open?path=/data/notebooks/your_notebook.livemd"
```

## How It Works

1. **Container Start**: Livebook starts with an auto-watcher background process
2. **Notebook Open**: When you open a `.livemd` file in the browser, the auto-watcher detects it and starts a file watcher for that notebook
3. **File Sync**: Any changes to the `.livemd` file are automatically synced to the open Livebook session
4. **MCP Server**: AI assistants can use the MCP server to interact with Livebook via `docker exec`

## Troubleshooting

### Watcher not connecting

The watcher only connects after you open the notebook in Livebook. Check logs:

```bash
docker compose logs --tail=20
```

### Port already in use

Change the port in `docker-compose.yml`:

```yaml
ports:
  - "8081:8080"  # Use port 8081 instead
```

### MCP server not working

1. Ensure the container is running: `docker compose ps`
2. Test the MCP server: `echo '{"jsonrpc":"2.0","method":"initialize","params":{},"id":1}' | ./scripts/mcp-docker.sh`
3. Restart Claude Code/Cursor after adding MCP configuration

## License

MIT

## Credits

- [Livebook](https://livebook.dev/) - Interactive notebooks for Elixir
- [livebook_tools](https://github.com/thmsmlr/livebook_tools) - MCP server and sync utilities
