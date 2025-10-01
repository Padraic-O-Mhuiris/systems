{inputs, ...}: {
  imports = [inputs.devshell.flakeModule];

  perSystem = {
    inputs',
    pkgs,
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
          hcloud
          just
        ]
        ++ [
          inputs'.nixos-anywhere.packages.default
          inputs'.terranix.packages.default
          inputs'.nixidy.packages.default
        ];
    };
  };
}
