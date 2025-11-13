# Claude MCP Configuration

This directory contains MCP (Model Context Protocol) server configurations for Claude Code.

## Figma MCP Server

The `mcp_config.json` file configures the Figma MCP server, which allows Claude Code to:
- Fetch Figma design data directly from URLs
- Extract layout, styling, and component information
- Download images and assets from Figma files
- Generate code from Figma designs

### Installation

1. Install the Figma MCP server (automatically via npx):
   ```bash
   npx -y figma-developer-mcp --version
   ```

2. Get your Figma Personal Access Token:
   - Go to https://www.figma.com/settings
   - Scroll to "Personal access tokens"
   - Click "Generate new token"
   - Copy the token

3. Copy the config to your Claude directory:
   ```bash
   mkdir -p ~/.config/claude
   cp mcp_config.json ~/.config/claude/claude_desktop_config.json
   ```

4. Update with your token:
   ```bash
   # Edit the file and replace YOUR_FIGMA_API_KEY_HERE with your actual token
   nano ~/.config/claude/claude_desktop_config.json
   ```

5. Restart Claude Code

### Usage

Once configured, you can ask Claude Code to:
- "Fetch this Figma design: [URL]"
- "Implement this Figma component: [URL]"
- "Download assets from this Figma file: [URL]"

The server will automatically parse Figma URLs and extract the necessary file and node IDs.

### Configuration Reference

```json
{
  "mcpServers": {
    "figma": {
      "command": "npx",
      "args": [
        "-y",
        "figma-developer-mcp",
        "--figma-api-key=YOUR_FIGMA_API_KEY_HERE",
        "--stdio"
      ]
    }
  }
}
```

### Troubleshooting

- **Connection errors**: Ensure your Figma token is valid and not expired
- **Permission errors**: Make sure the token has access to the files you're trying to fetch
- **Server not found**: Run `npx -y figma-developer-mcp --version` to verify installation

For more information, visit:
- [Figma MCP Server Documentation](https://github.com/GLips/Figma-Context-MCP)
- [Model Context Protocol](https://modelcontextprotocol.io)
