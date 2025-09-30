# Terminal Environment Configuration

Comprehensive terminal and shell configuration providing modern CLI tooling and workflow optimization across all hosts.

## Architecture

The terminal profile orchestrates multiple components:
- **Shell environment**: Zsh with advanced configuration
- **Terminal emulators**: WezTerm (primary) and Ghostty (lightweight)
- **Command history**: Atuin for searchable, synced command history
- **CLI tooling**: Modern replacements for traditional Unix tools

## Shell Configuration (`shell/`)

### Zsh Setup (`shell/zsh/`)
Modern shell with productivity enhancements:
- **Framework**: Oh-my-zsh with carefully selected plugins
- **Completion system**: Advanced tab completion with fuzzy matching  
- **Prompt**: Informative prompt with git status and system info
- **History**: Persistent, searchable history with Atuin integration

### Aliases (`shell/aliases.nix`)
Modern CLI tool mappings:
- `ls` → `eza` (better file listing)
- `cat` → `bat` (syntax highlighting)
- `grep` → `rg` (ripgrep for speed)
- `find` → `fd` (user-friendly find)
- Git shortcuts and workflow aliases

### Command History (`shell/atuin.nix`)
Synchronized command history across machines:
- **Encrypted sync**: Commands synced via Atuin service
- **Contextual search**: Search by directory, command, time
- **Statistics**: Command usage analytics and insights
- **Privacy**: Local-only mode available

## Terminal Emulators

### WezTerm (`wezterm/`)
Primary GPU-accelerated terminal emulator:
- **Configuration**: Lua-based configuration system
- **Features**: Tabs, splits, workspaces, multiplexing
- **Performance**: Hardware acceleration for smooth scrolling
- **Integration**: Wayland native with excellent font rendering
- **Modules**:
  - `modules/utils.lua` - Utility functions and helpers
  - `modules/workspace.lua` - Workspace and session management
  - `wezterm.lua` - Main configuration entry point

### Ghostty (`ghostty/`)
Lightweight alternative terminal:
- **Performance**: Minimal resource usage
- **Speed**: Fast startup and rendering
- **Simplicity**: Focused feature set for basic terminal needs

## CLI Tool Ecosystem

The profile provides modern CLI tools as standard:

### File Management
- **eza**: Enhanced `ls` with git status, icons, tree view
- **fd**: Fast, user-friendly file finder
- **bat**: Syntax-highlighted file viewer with paging
- **rg (ripgrep)**: Extremely fast text search

### Development Tools
- **jq/yq**: JSON/YAML processing and querying
- **fzf**: Fuzzy finder for files, history, processes
- **delta**: Enhanced git diff viewer
- **gh**: GitHub CLI for repository management

### System Tools  
- Modern replacements available but traditional tools preserved for compatibility

## Wayland Integration

Terminal emulators configured for optimal Wayland experience:
- **Native protocols**: Using Wayland-specific features
- **Clipboard integration**: Proper clipboard handling
- **Font rendering**: Subpixel rendering configuration
- **Window management**: Integration with tiling window managers

## Workflow Optimization

### Command History Workflow
1. Commands automatically captured by Atuin
2. Sync encrypted history across all hosts  
3. Search with `Ctrl+R` using contextual filters
4. Access statistics and frequently used commands

### Terminal Multiplexing
WezTerm provides built-in multiplexing:
- **Workspaces**: Logical groupings of terminal sessions
- **Tabs**: Multiple terminals in single window
- **Splits**: Divide terminal into panes
- **Sessions**: Persistent terminal sessions

### Modern CLI Workflow
Standard workflow uses modern tools:
```bash
fd pattern | rg search_term  # Find files then search content
eza --tree --git-ignore      # Show directory structure
bat file.json | jq '.key'    # View and parse JSON
```

## Configuration Management

### Declarative Configuration
All terminal configuration managed through Nix:
- Shell RC files generated from Nix expressions
- Terminal emulator configs templated with Nix
- Tool configurations unified across hosts

### Secrets Integration
Sensitive configuration (API keys for Atuin) managed via sops-nix:
- Atuin sync key encrypted per-host
- Shell history encryption keys
- Service authentication tokens