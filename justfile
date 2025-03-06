
update-secrets:
    nix flake update secrets
    git add ./flake.lock
    git commit -m "bump flake input secrets"
