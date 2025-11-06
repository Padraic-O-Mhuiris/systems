# Nix K8s Module System

## Goal
Generate NixOS-style module system for Kubernetes from OpenAPI schema. Zero IFD, pure eval.

## Architecture
```
OpenAPI Schema (JSON)
  → Parser (extract definitions, types, fields)
  → Codegen (generate module definitions)
  → Commit generated .nix files
  → Module evaluation
  → KYAML serialization
```

## Core Components

### 1. Schema Processing
- Download K8s OpenAPI spec (v1.28+)
- Parse definitions, group by API version
- Map OpenAPI types → Nix module types

### 2. Code Generation (ahead-of-time, committed)
- Generate `lib.types.submodule` for each K8s resource
- Handle required/optional fields
- Resolve `$ref` references
- Output: `generated/v1.30/{core,apps,batch}.nix`

### 3. Module System
```nix
{
  kubernetes.pods.<name> = { metadata = ...; spec = ...; };
  kubernetes.deployments.<name> = { ... };
  kubernetes.services.<name> = { ... };
}
```

### 4. Evaluation & Serialization
```nix
evalConfig → collect resources → toKYAML → deploy
```

## Type Mapping
- `string` → `lib.types.str`
- `integer` → `lib.types.int`
- `boolean` → `lib.types.bool`
- `array` → `lib.types.listOf`
- `object` → `lib.types.submodule` or `attrsOf`
- `$ref` → resolve to generated type

## Output Format
**KYAML** (JSON-like with comments, unquoted keys, trailing commas)
- Easy to serialize
- Easy to parse (minimal normalization → `builtins.fromJSON`)
- K8s 1.34+ native support

## Advantages
- ✅ No IFD (generated code committed)
- ✅ Type safety (module system validation)
- ✅ Complete K8s coverage (auto-generated from schema)
- ✅ Multi-version support (generate for 1.28, 1.29, 1.30)
- ✅ Pure evaluation (works in `nix flake check`)

## Key Decisions
- Generate modules ahead-of-time (not at eval-time)
- Commit generated code to repo
- Use KYAML as primary output format
- Support multiple K8s versions via versioned schemas

## Critical Architecture Decisions

### Forward Reference Resolution
K8s types reference each other heavily (Pod → PodSpec → Container → Volume → ...). Solution: Use `lib.fix` to create recursive scope where all types can reference each other:

```nix
lib.fix (types: {
  Pod = import ./Pod.nix { inherit lib types; };
  PodSpec = import ./PodSpec.nix { inherit lib types; };
  # All 700+ types available to each other
})
```

Each type file receives `types` argument for cross-references. No multi-pass generation needed—Nix's lazy evaluation handles forward refs naturally.

### Generated Code Size & Strategy
- Estimated size: 3-5MB for all ~700 types (not 50MB)
  - 700 types × ~20 fields × ~120 chars/field = 1.7MB base
  - Plus descriptions, nested submodules = 3-5MB total
- **One file per type** for modularity
- `default.nix` index (~100KB) imports all type files
- Lazy evaluation: Only used types are evaluated (e.g., using just Pod+Service+Deployment evaluates ~50 types, not all 700)

### Commit Generated Code
**Decision: Yes, commit all generated .nix files**

Rationale:
- Zero IFD (works in `nix flake check`)
- No network access during eval (reproducible)
- Fast evaluation (no generation overhead)
- Git tracks K8s version changes (diff between 1.29 → 1.30)
- 3-5MB is trivial for modern git

### Rust Codegen Tooling
- Use `k8s-openapi-codegen-common` crate (already parses K8s OpenAPI, handles quirks)
- Simple string generation (not AST manipulation)
- Single-pass generation (no stubs needed due to lib.fix)

### CRD Support
- Extract OpenAPI schema from CRD `spec.versions[].schema.openAPIV3Schema`
- Process identically to K8s built-in types
- Generate to same output directory with proper namespacing
- Usage: `cargo run -- --schema v1.30.json --crds mycrd.yaml`

### Dual-Layer Design: Strict Types + Ergonomic Builders

**Layer 1: Module System (Strict Compliance)**
- Auto-generated from OpenAPI schema
- Enforces exact K8s API specification
- Direct 1:1 mapping to upstream docs
- Type checking via NixOS module system
- Example: `ports = [{ containerPort = 80; protocol = "TCP"; }]`

**Layer 2: Functional Library (Ergonomic Construction)**
- Also auto-generated from OpenAPI schema
- Provides `mk*` helper functions for complex types
- Explicit, composable, discoverable
- Returns strictly-typed structures (validates against Layer 1)
- Example: `ports = map k8s.mkPort [ 80 443 ]`

**Design Rationale:**
- **Separate but inherited**: Library functions build structures that conform to strict types
- **No magic coercion**: User explicitly calls helpers, behavior is clear
- **Optional usage**: Can use strict types directly or ergonomic helpers
- **Auto-generated both**: Derive helpers from schema patterns (name/value pairs, simple wrappers, etc.)
- **Familiar pattern**: Follows Nix conventions (`mkDerivation`, `mkOption`, etc.)

**Generated Structure:**
```
generated/v1.30/
├── types/          # Layer 1: Strict module types
│   ├── default.nix
│   └── *.nix
└── lib/            # Layer 2: Ergonomic builders
    ├── default.nix
    ├── containers.nix  (mkContainer, mkPort, mkEnv)
    ├── metadata.nix    (mkMetadata, mkLabels)
    └── resources.nix   (mkResources, mkQuantity)
```

**Usage Example:**
```nix
{ k8s-types, k8s }:
kubernetes.pods.nginx = k8s-types.Pod {
  spec.containers = [
    (k8s.mkContainer "nginx" "nginx:1.21" {
      ports = map k8s.mkPort [ 80 443 ];
      env = k8s.mkEnvVars { FOO = "bar"; };
    })
  ];
};
```

### Two-Stage Codegen: Pure vs. Enhanced

**Stage 1: Pure Translation (required)**
- Mechanical 1:1 mapping from OpenAPI to Nix types
- No interpretation or enhancement
- Always stable, tracks K8s versions exactly
- Example: `schedule: string` → `type = lib.types.str`

**Stage 2: Opinionated Enhancement (optional)**
- Adds validation for well-known patterns
- Applied by codegen tool based on field patterns and semantics
- Can be enabled/disabled per generation
- User can choose pure or enhanced types

**Enhancement Candidates:**
- **Cron expressions**: `"0 * * * *"` - validate format, support `@daily` shortcuts
- **Duration strings**: `"10s"`, `"5m"`, `"2h"` - validate K8s duration format
- **Resource quantities**: `"100Mi"`, `"2Gi"`, `"500m"` - validate memory/CPU notation
- **DNS labels**: Validate RFC 1123 compliance for names
- **Semantic constraints**: Non-negative integers, port ranges (1-65535)

**Generated Output:**
```
generated/v1.30/
├── types/          # Stage 1: Pure OpenAPI types
│   └── ...
├── enhanced/       # Stage 2: With validation (optional)
│   └── ...
└── lib/            # Ergonomic builders (works with both)
    └── ...
```

**Example Enhancement:**
```nix
# Pure (Stage 1)
schedule = lib.mkOption { type = lib.types.str; };

# Enhanced (Stage 2)
schedule = lib.mkOption {
  type = lib.types.strMatching "^(@(yearly|monthly|weekly|daily|hourly)|((\\*|[0-9]+)...))$";
  description = lib.mdDoc "Cron expression (e.g., '0 * * * *' or '@daily')";
};
```

**Rationale:**
- Stage 1 never breaks, always tracks upstream
- Stage 2 catches errors at eval time vs. K8s API rejection time
- Users choose their preference (strict correctness vs. flexibility)
- Enhancements evolve independently from base types

### Auto-Generated Serialization (`__toString`)

**Every generated K8s type includes `__toString`** for automatic KYAML serialization.

**Implementation:**
```nix
# Auto-generated in every resource type
Pod = lib.types.submodule {
  options = { ... };
  config = {
    __toString = self: toKYAML (builtins.removeAttrs self ["__toString" "_module"]);
  };
};
```

**Benefits:**

1. **Direct evaluation**
   ```bash
   nix eval .#kubernetes.pods.nginx --raw > nginx.yaml
   nix eval .#kubernetes.pods.nginx --raw | kubectl apply -f -
   ```

2. **Easy debugging**
   ```nix
   let
     pod = { spec = { ... }; };
   in
     builtins.trace "${pod}" pod  # Prints YAML during eval
   ```

3. **String interpolation**
   ```nix
   writeFile "manifest.yaml" ''
     ${kubernetes.pods.nginx}
     ---
     ${kubernetes.services.nginx}
   ''
   ```

4. **No manual serialization**
   ```nix
   # Just works - no toYAML calls needed
   "${myPod}"  # → KYAML string
   ```

**Collection Serialization:**
```nix
# Serialize all resources in a namespace
toString (lib.attrValues kubernetes.namespaces.production.pods)
# Outputs multi-document YAML with --- separators
```

**Rationale:**
- Makes every K8s expression directly inspectable
- Debugging is trivial: just print the value
- Natural integration with Nix string operations
- No ceremony for deployment workflows

### Validation & Testing Strategy

**Goal**: Verify generated YAML is valid before deployment to cluster.

**Primary Validation: kubeconform (Offline)**
```bash
# Fast schema validation, no cluster required
nix eval .#kubernetes.pods.nginx --raw | kubeconform -strict -

# Validate against specific K8s version
kubeconform -kubernetes-version 1.30.0 -strict manifest.yaml

# Support CRDs via schema location
kubeconform -schema-location default -schema-location 'schemas/{{.ResourceKind}}.json' -
```

**Benefits:**
- ✅ Offline validation (no cluster access needed)
- ✅ Fast execution (perfect for CI/CD)
- ✅ Supports CRD validation
- ✅ Validates against OpenAPI schema

**Secondary Validation: kubectl dry-run**
```bash
# Server-side validation (most thorough, requires cluster)
nix eval .#kubernetes.pods.nginx --raw | kubectl apply --dry-run=server -f -

# Client-side validation (offline, less thorough)
nix eval .#kubernetes.pods.nginx --raw | kubectl apply --dry-run=client -f -
```

**Integration with Nix Checks:**
```nix
# flake.nix
{
  checks.x86_64-linux = {
    # Schema validation (runs in CI)
    validate-manifests = pkgs.runCommand "validate-k8s" {
      nativeBuildInputs = [ pkgs.kubeconform ];
    } ''
      ${pkgs.nix}/bin/nix eval .#allResources --raw | \
        kubeconform -strict -kubernetes-version 1.30.0 - > $out
    '';

    # Structure tests
    test-pod-structure = pkgs.runCommand "test-structure" {
      nativeBuildInputs = [ pkgs.yq ];
    } ''
      ${pkgs.nix}/bin/nix eval .#kubernetes.pods.nginx --raw | \
        yq eval '.kind' - | grep -q 'Pod'
      touch $out
    '';
  };
}
```

**Run tests:**
```bash
# Local development
nix flake check

# CI pipeline
nix build .#checks.x86_64-linux.validate-manifests
```

**Advanced: Policy Validation (Optional)**
```bash
# Use conftest/OPA for security policies
nix eval .#kubernetes.pods.nginx --raw | conftest test -p policy -
```

**Recommended Strategy:**
1. **Dev time**: Type checking via module system (instant feedback)
2. **Pre-commit**: `kubeconform` validation (fast, offline)
3. **CI/CD**: `kubeconform` + optional `kubectl dry-run`
4. **Production**: Optional policy validation (OPA/conftest)

## Implementation Order
1. Project structure
2. Download schema
3. Schema parser
4. Module codegen (start with Pod)
5. Test & validate
6. Full generation
7. KYAML serializer
8. Public API

## Project Structure
```
nix-k8s/
├── flake.nix
├── schema/
│   ├── download.sh              # Fetch OpenAPI schemas
│   ├── v1.28.json
│   ├── v1.29.json
│   └── v1.30.json
├── generator/
│   ├── default.nix              # Main generator entry
│   ├── parser.nix               # Parse OpenAPI JSON
│   ├── types.nix                # OpenAPI → Nix type mapping
│   └── codegen.nix              # Generate module code
├── generated/
│   └── v1.30/
│       ├── core.nix             # v1 resources (Pod, Service, etc.)
│       ├── apps.nix             # apps/v1 (Deployment, StatefulSet)
│       ├── batch.nix            # batch/v1 (Job, CronJob)
│       ├── networking.nix       # networking.k8s.io/v1
│       └── types.nix            # Common types (ObjectMeta, etc.)
├── lib/
│   ├── kyaml.nix               # KYAML serializer
│   ├── modules.nix             # Module system integration
│   └── default.nix             # Public API
└── examples/
    ├── simple-pod.nix
    ├── web-app.nix
    └── multi-tier.nix
```

## Usage Example
```nix
# examples/simple-pod.nix
{
  kubernetes.pods.nginx = {
    apiVersion = "v1";
    kind = "Pod";
    metadata = {
      name = "nginx";
      namespace = "default";
      labels.app = "web";
    };
    spec.containers = [{
      name = "nginx";
      image = "nginx:1.21";
      ports = [{ containerPort = 80; }];
    }];
  };
}
```

## Deployment
```bash
# Generate manifests
nix eval .#manifests.webapp --raw > webapp.yaml

# Apply to cluster
kubectl apply -f webapp.yaml

# Or pipe directly
nix eval .#manifests.webapp --raw | kubectl apply -f -
```
