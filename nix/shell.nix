{inputs, ...}: {
  imports = [inputs.devshell.flakeModule];

  perSystem = {
    inputs',
    pkgs,
    self',
    ...
  }: {
    devshells.default = {
      packages = with pkgs;
        [
          curl
          kubectl
          podman
          # kubernetes-helm
          kind
          k9s

          alejandra
          git
          just

          nodejs
        ]
        ++ [
          inputs'.nixos-anywhere.packages.default
          inputs'.nixidy.packages.default
        ]
        ++ [self'.packages.hcloud];
    };
  };
}
