# Claude Code Configuration Profile

This directory contains the Claude Code configuration layer for all hosts in this repository.

## Purpose

Provides declarative NixOS/home-manager configuration for Claude Code CLI, including:
- Sandboxed execution via bubblewrap (`nix/modules/homeManager/cc.nix`)
- API key management through sops-nix secrets
- Per-host Claude Code settings and environment

## Architecture

### Core Components

**`nix/modules/homeManager/cc.nix`** - Custom home-manager module that:
- Wraps Claude Code CLI in a bubblewrap sandbox for security isolation
- Creates `cc` wrapper command that:
  - Isolates Claude's home directory to `/tmp` for YOLO mode safety
  - Mounts git repo root read-write, parent tree read-only
  - Provides API key access via `~/.claude_api_secret`
  - Shares network, essential tools, and Nix daemon socket
- Manages settings.json, CLAUDE.md, agents, commands, hooks via home-manager
- Supports MCP server configuration
- Includes essential CLI tools in sandbox: git, rg, fd, jq, nix

### Sandbox Security Model

The bubblewrap sandbox provides:
- Isolated `/tmp` home directory (prevents YOLO mode from touching real home)
- Read-only `/nix`, `/usr`, `/bin`, `/etc` mounts
- Read-write access to current git repository
- Read-only access to parent directory tree (when repo is under `~/`)
- Network access enabled
- API keys mounted from host filesystem

## Structure

- `default.nix` - Main profile enabling Claude Code with secrets integration
- `claude/` - Host-specific Claude Code configuration directory
  - `agents/` - System-wide custom agents (symlinked to `~/.claude/agents/`)
  - `commands/` - System-wide custom commands (symlinked to `~/.claude/commands/`)
  - `hooks/` - System-wide custom hooks (symlinked to `~/.claude/hooks/`)

## Usage

Import this profile in host configurations to enable Claude Code with proper secrets management and sandboxing. The `cc` command launches Claude Code in the sandbox.

## Adding Agents, Commands, and Hooks

When creating system-wide agents, commands, or hooks:
1. Add files to `profiles/ai/claude/{agents,commands,hooks}/`
2. Reference them in `profiles/ai/default.nix` using the module's directory options:
   - `programs.cc.agentsDir = ./claude/agents;`
   - `programs.cc.commandsDir = ./claude/commands;`
   - `programs.cc.hooksDir = ./claude/hooks;`

This approach keeps all Claude Code configuration declarative and version-controlled within the NixOS configuration.