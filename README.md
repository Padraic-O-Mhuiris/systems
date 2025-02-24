# Systems

Repository for managing all my nixos-configurations for various machines

# Todos

- \[\] Create a minimal nixos installation target

# Links

- [nh/nix-helper](https://github.com/viperML/nh)
  Reimplementation of various NixOS ecosystem tooling

- [Awesome Nix](https://nix-community.github.io/awesome-nix/)

- [Yubikey QoL](https://www.youtube.com/watch?v=3CeXbONjIgE)

  - This guy has some great content [Near unattended remote install](https://unmovedcentre.com/posts/remote-install-nixos-config/)
  - Really nice way of defining [global variables](https://unmovedcentre.com/posts/remote-install-nixos-config/#configvars)

- [erictossel/nixflake](https://github.com/erictossell/nixflakes)

- [nixos-generators](https://github.com/nix-community/nixos-generators)

  useful for building configurations for different targets

# Notes

- `environment.systemPackages` allows for inheritance instead of a list

  ```nix
    environment.systemPackages = {
      inherit (pkgs)
        firefox # I'm installing packages like this now
        ;
    };
  ```

- [Storing secrets in a private repo](https://www.youtube.com/watch?v=HnmpYp1_aKo)
  Considering this is a good approach
