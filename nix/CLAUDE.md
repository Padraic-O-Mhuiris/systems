# Development Infrastructure and Custom Modules

Development tooling, custom NixOS/home-manager modules, and build infrastructure for this flake-based NixOS configuration.

## Directory Organization

### Build Configuration
- **`default.nix`**: Main module exports and flake-parts integration
- **`formatter.nix`**: Code formatting with alejandra
- **`checks.nix`**: Linting and validation with statix
- **`shell.nix`**: Development shell with tools and dependencies

### Custom Modules (`modules/`)
Reusable modules extending NixOS and home-manager:

#### Home Manager Modules (`modules/homeManager/`)
- **`cc.nix`**: Claude Code sandboxing and integration module
- **`default.nix`**: Module aggregation and exports

#### NixOS Modules (`modules/nixos/`) 
- **`default.nix`**: System-level module definitions (currently minimal)

### Utility Libraries (`lib/`)
- **`default.nix`**: Helper functions and utilities for configuration

### Package Definitions (`packages/`)
Custom package definitions and overlays (currently empty).

## Custom Module Architecture

### Claude Code Module (`modules/homeManager/cc.nix`)
Sophisticated home-manager module providing:

**Sandboxing via Bubblewrap**:
- Isolates Claude Code execution in secure container
- Mounts read-write access to current git repository
- Provides read-only access to parent directory tree
- Isolates home directory to `/tmp` for safety
- Preserves network access and essential system mounts

**Configuration Management**:
- Declarative Claude Code settings through home-manager
- Managed API key injection from secrets
- System-wide agents, commands, and hooks
- Custom CLAUDE.md file management

**Security Model**:
- Prevents YOLO mode from affecting real home directory  
- Controlled filesystem access - only git repositories
- Network isolation options
- API key protection through secure mounting

### Module Options Pattern
Custom modules follow consistent option patterns:
```nix
options.programs.cc = {
  enable = mkEnableOption "Claude Code";
  package = mkOption { type = types.package; };
  settings = mkOption { type = types.attrs; };
  # Directory options for agents, commands, hooks
  agentsDir = mkOption { type = types.nullOr types.path; };
};
```

## Development Workflow

### Code Quality Pipeline
```bash
# Format all Nix code
nix fmt

# Run static analysis and linting  
nix flake check

# Enter development shell with all tools
nix develop
```

### Module Development
1. **Create module**: Add to appropriate subdirectory
2. **Define options**: Use NixOS module system conventions  
3. **Implement config**: Transform options into system configuration
4. **Export module**: Add to default.nix exports
5. **Test integration**: Use in profiles or host configurations

### Testing Custom Modules
```bash
# Test module syntax and evaluation
nix-instantiate --eval --expr '(import ./modules/homeManager/cc.nix {}).options'

# Test module in isolation
home-manager switch --flake .#testProfile

# Full system test
nixos-rebuild test --flake .#TestHost
```

## Integration with Flake Architecture

### Flake-Parts Integration
Development infrastructure integrates with main flake via flake-parts:
```nix
# flake.nix
imports = [ ./nix ];

# nix/default.nix exports:
perSystem = { pkgs, ... }: {
  formatter = pkgs.alejandra;
  checks.statix = pkgs.statix.check;
  devShells.default = pkgs.mkShell { /* ... */ };
};

flake.homeManagerModules = {
  cc = import ./modules/homeManager/cc.nix;
};
```

### Module Distribution
Custom modules available to:
- **Host configurations**: Direct import from nix/modules/
- **External flakes**: Via flake outputs homeManagerModules/nixosModules
- **Profile system**: Imported by profiles for reusable configuration

## Dependency Management

### Development Dependencies
Development shell provides:
- **alejandra**: Nix code formatter
- **statix**: Static analysis and linting
- **nix-tree**: Dependency visualization  
- **nixos-rebuild**: System deployment tools
- **home-manager**: User environment management

### Runtime Dependencies
Custom modules manage their own runtime dependencies:
- **bubblewrap**: Sandboxing for Claude Code module
- **git**: Repository management in sandbox
- **curl/wget**: Network tools for sandboxed environments

## Module Security Considerations

### Sandboxing Implementation
Claude Code module implements defense-in-depth:
- **Filesystem isolation**: Limited mount points
- **Process isolation**: Separate namespace
- **Network control**: Configurable network access
- **Capability restriction**: Minimal Linux capabilities

### Secrets Integration
Secure handling of sensitive configuration:
- **API keys**: Never stored in Nix store
- **Runtime injection**: Secrets mounted at runtime
- **Encryption**: All secrets encrypted with sops-nix
- **Per-host isolation**: Each host has separate secret namespace

## Extension Points

### Adding New Modules
1. Create module in appropriate subdirectory
2. Follow NixOS module system conventions
3. Add comprehensive option documentation
4. Include example usage and testing
5. Export through default.nix aggregation

### Extending Existing Modules
Custom modules designed for extension:
- **Option composition**: Combine multiple configuration sources
- **Hook systems**: Allow profile/host-specific customization  
- **Overlay support**: Enable package customization