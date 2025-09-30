# Secrets Management Workflow

This document describes the secrets management approach used in this NixOS configuration repository.

## Architecture Overview

### Components
- **Private Secrets Flake**: External repository containing encrypted secrets
- **sops-nix**: NixOS module for secrets decryption and deployment
- **Age encryption**: Used for encrypting secrets files
- **SSH keys**: Used as Age keys for decryption

### Repository Structure
```
Main Repository (this repo)
├── flake.nix                    # References secrets flake input
├── profiles/common/secrets.nix   # Imports secrets modules
└── profiles/*/                   # Individual profiles using secrets

External Secrets Repository (.secrets)
├── nixosModules/               # NixOS-level secrets
├── homeModules/               # Home-manager secrets
└── secrets/                   # Encrypted .yaml files
```

## Setup Process

### Initial Configuration
1. **Secrets Repository**: Private Git repository (.secrets) containing:
   - Encrypted YAML files with secrets
   - NixOS modules that reference these secrets
   - Age/sops configuration

2. **SSH Key Management**:
   - Age keys stored in `/persist/etc/ssh/` for persistence across reboots
   - SSH keys serve dual purpose: system access + secrets decryption

3. **Bootstrap Integration**:
   - Bootstrap script handles SSH key deployment during installation
   - Pass (password store) manages SSH keys and disk encryption during setup

## Daily Workflow

### Updating Secrets
```bash
# Update secrets flake input
just update-secrets

# Or manually:
nix flake update secrets
git add ./flake.lock
git commit -m "bump flake input secrets"
```

### Using Secrets in Modules

#### NixOS Level (profiles/common/secrets.nix)
```nix
{
  imports = [
    inputs.secrets.nixosModules.default
  ];
}
```

#### Home Manager Level
```nix
home-manager.users.${vars.PRIMARY_USER.NAME} = _: {
  imports = [
    inputs.secrets.homeModules.default
  ];
};
```

#### Individual Module Usage
```nix
# Example from profiles/users/primary.nix
sops.secrets."${vars.PRIMARY_USER.NAME}_password" = {
  # Configuration for user password
};

users.users.${vars.PRIMARY_USER.NAME} = {
  hashedPasswordFile = config.sops.secrets."${vars.PRIMARY_USER.NAME}_password".path;
};
```

## Security Model

### Encryption
- **Algorithm**: Age encryption (modern, simple)
- **Key Management**: SSH keys stored in `/persist/etc/ssh/`
- **Access Control**: Only machines with correct SSH keys can decrypt

### Key Distribution
- **Bootstrap**: SSH keys deployed during initial installation via Pass
- **Persistence**: Keys survive reboots via `/persist` directory
- **Rotation**: Update keys in secrets repository, then update flake

### Scope of Secrets
Based on current usage:
- **User passwords**: Hashed passwords for system users
- **Service credentials**: Atuin session tokens and API keys
- **Network credentials**: WiFi passwords (via Lithium integration)

## Troubleshooting

### Common Issues
1. **Decryption failures**: Verify SSH keys in `/persist/etc/ssh/`
2. **Secrets not updating**: Run `just update-secrets` to refresh
3. **Bootstrap issues**: Ensure Pass contains required SSH keys

### Key Locations
- **Age keys**: `/persist/etc/ssh/` (persisted across reboots)
- **Secrets repository**: `git+ssh://git@github.com/Padraic-O-Mhuiris/.secrets.git`
- **Module imports**: Individual modules reference `sops.secrets.*`

## Best Practices

### Adding New Secrets
1. Add encrypted secret to .secrets repository
2. Create module in .secrets that references the secret
3. Import and use in main repository modules
4. Update flake input with `just update-secrets`

### Key Rotation
1. Generate new SSH keys
2. Update .secrets repository with new public keys
3. Deploy new keys to `/persist/etc/ssh/` on all hosts
4. Update secrets flake input

### Security Considerations
- Keep .secrets repository private and access-controlled
- Regularly rotate SSH keys used for encryption
- Monitor access to secrets repository
- Use minimal required permissions for service accounts