#!/bin/bash
# MCP server wrapper that runs inside the Docker container
# Use this as the MCP server command in Claude Code

exec docker exec -i livebook livebook_tools mcp_server
