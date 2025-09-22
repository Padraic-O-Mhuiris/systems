# Project TODO

## Active Projects

### Carbon Deployment
- **Status**: Planning phase
- **Description**: Deploy Carbon as Kubernetes cluster on Hetzner Cloud
- **Current State**: Terraform config exists but commented out in `hosts/Carbon/default.nix`
- **Next Steps**:
  - Uncomment and configure Terraform infrastructure
  - Add Carbon to nixosConfigurations in `hosts/default.nix`
  - Create proper NixOS configuration for server role

## Completed Projects

### WezTerm-Helix Integration
- **Status**: Reverted
- **Description**: File watcher for automatic helix reloads on external file changes
- **Outcome**: Implementation completed but reverted per user request

## Ideas / Future Considerations

### System Monitoring
- Add monitoring across all hosts
- Implement metrics collection and alerting

### Backup Strategy
- Automated backups for persistent data
- Recovery procedures documentation

### Development Workflow Improvements
- Enhanced editor integrations
- Build system optimizations

---
*Last updated: 2025-09-22*