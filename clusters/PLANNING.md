# Personal Kubernetes Cloud Infrastructure Planning

## Overview
Build a fully custom Nix + Kubernetes personal cloud on Hetzner VPS for self-hosting. Focus on reproducible, declarative infrastructure with incremental scaling approach.

## Target Architecture (~€218/month)

### Control Plane (3 nodes)
- **Instance**: Hetzner CPX11 (1 vCPU, 2GB RAM)
- **Cost**: €3.29/month × 3 = €9.87/month
- **Purpose**: HA Kubernetes control plane (odd number for raft consensus)

### Worker Nodes (5 nodes)
- **Instance**: Hetzner CCX23 (4 vCPU, 16GB RAM, 80GB NVMe)
- **Cost**: €14.62/month × 5 = €73.10/month
- **Storage**: +500GB block storage per node = €125/month
- **Total Workers**: €198.10/month

### Specialized Nodes
- **Oxygen Desktop**: Containerized Nix remote builder + cluster worker
- **Future**: Potential GPU nodes for AI workloads

## Storage Strategy

### Performance Tiers
- **Hot (NVMe)**: ETH node active state, databases, app caches (500GB-1TB per worker)
- **Warm (Block storage)**: Recent snapshots, short-term backups (500GB per worker)
- **Cold (S3/Object)**: Archives, long-term backups (~€0.01-0.02/GB/month)

### Application Examples
- ETH nodes: ~100-500GB active data
- General websites: Low I/O requirements
- Financial analysis: Burst CPU, moderate memory (not HFT)

## State Management Philosophy

### Core Principle
- **Kubernetes + provisioning reproducible** = problem solved for most cases
- **Selective data preservation** only where it matters (application-specific)

### Backup Integration
- Backup as part of Nix provisioning process
- Self-healing recovery from Git + backups
- No universal backup strategy - handled per application as needed

## Incremental Implementation Phases

### Phase 1: Single VPS (~€15/month)
- **Goal**: Prove Nix → Kubernetes → app workflow
- **Instance**: Single CCX23
- **Scope**: Basic cluster, simple stateless app, provisioning patterns
- **Duration**: Initial MVP testing

### Phase 2: HA Control Plane (~€25/month)
- **Goal**: Add reliability and multi-node patterns
- **Add**: 3×CPX11 masters, convert Phase 1 to worker
- **Scope**: Cluster operations, failover testing

### Phase 3: Scale Workers (~€50-150/month)
- **Goal**: Add capacity for real workloads
- **Add**: 2-4 additional CCX23 workers as needed
- **Scope**: Storage patterns, performance testing

### Phase 4: Full Target (~€218/month)
- **Goal**: Complete production-ready infrastructure
- **Add**: Remaining workers to reach 3+5 architecture
- **Scope**: All planned self-hosted services

## Provisioning Approach

### Nix-Based Infrastructure as Code
- **Terranix**: Terraform configurations written in Nix
- **Kubenix**: Kubernetes manifests generated via Nix
- **nixos-anywhere**: NixOS installation and configuration
- **GitOps**: Application deployment via Flux v2

### Cross-System Configuration Benefits
- **Type safety**: Catch configuration errors at build time across entire stack
- **Cross-referencing**: Single source of truth for infrastructure topology
- **YAML elimination**: No more YAML generation and maintenance headaches
- **Flake-parts integration**: Infrastructure, K8s, and NixOS configs in unified flake

### Secrets-Based Infrastructure References
```nix
# In private secrets flake - infrastructure topology as secrets
vars.CLUSTER = {
  MASTER_1 = {
    ip = "10.0.1.10";
    hetzner_id = "12345";
  };
  WORKER_1 = {
    ip = "10.0.1.20";
    hetzner_id = "67890";
  };
};

# Usage across stack - clean references without exposing topology
terraform.hetzner_server.master1.server_type = "cpx11";
kubernetes.apiserver.advertise_address = vars.CLUSTER.MASTER_1.ip;
nixos.networking.interfaces.eth0.ipv4.addresses = [{
  address = vars.CLUSTER.MASTER_1.ip;
  prefixLength = 24;
}];
```

### Security Model
- **Public repo**: Shows configuration intent, not sensitive details
- **Private secrets**: All IPs, server IDs, API keys via vars pattern
- **Consistent pattern**: Same `vars.PRIMARY_USER.NAME` approach extended to cluster
- **Network obfuscation**: Infrastructure topology hidden from public view

### Terraform State Management
**Approach**: Local encrypted state in private secrets repository
- **Location**: `secrets/cluster/terraform.tfstate.age` (encrypted with age)
- **Benefits**: Full ownership, no external dependencies, zero additional costs
- **Workflow**: Decrypt → terraform plan/apply → re-encrypt → commit to secrets repo

**Global coordination between repos:**
```nix
# In main system flake.nix
inputs.secrets.url = "path:/home/padraic/secrets";

# terranix references secrets repo location
terraform.backend.local.path = "${inputs.secrets}/cluster/terraform.tfstate";
```

**Update script pattern:**
```bash
#!/usr/bin/env bash
SYSTEM_REPO="/home/padraic/systems"
SECRETS_REPO="/home/padraic/secrets"

cd $SECRETS_REPO/cluster
age -d terraform.tfstate.age > terraform.tfstate
terraform plan/apply
age -e -r <pubkey> terraform.tfstate > terraform.tfstate.age
rm terraform.tfstate && git add . && git commit

cd $SYSTEM_REPO
# Commit any terranix changes that reference new resources
```

**Rationale**: Solo user, full control, simple workflow, integrated with existing secrets management

### Networking
- **Tailscale**: Secure overlay network connecting all nodes
- **Hetzner private networks**: High-performance inter-VPS communication
- **Public IPs**: External service access

## Build Infrastructure

### Nix Remote Building
- **Primary**: Containerized builder on Oxygen desktop
- **Secondary**: Light builds on cluster nodes
- **Binary Cache**: Served from cluster for reliability
- **Rationale**: Leverage existing powerful hardware, avoid expensive build VPS

### Container Strategy
- **Builder isolation**: Docker/Podman container on Oxygen
- **Cluster integration**: Oxygen joins as specialized worker node
- **Management**: Builder container managed via Kubernetes when possible

## Key Design Decisions

1. **Cloud-first**: Start with Hetzner VPS, add local hardware later
2. **HA from start**: 3-node control plane for proper multi-master patterns
3. **Incremental scaling**: Pay only for current needs, proven growth path
4. **Performance-conscious**: CCX23 adequate for planned workloads
5. **Hybrid building**: Use existing desktop power, serve cache from cloud
6. **Practical state management**: Reproducible infrastructure + selective backups

## Next Steps
1. Begin Phase 1: Single VPS with basic Kubernetes
2. Establish Terraform + nixos-anywhere workflow
3. Deploy first stateless application
4. Prove destroy/rebuild cycle works reliably
5. Scale incrementally through remaining phases