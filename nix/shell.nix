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
          alejandra
          git
          hcloud
          just
          terraform
        ]
        ++ [
          inputs'.nixos-anywhere.packages.default
          inputs'.terranix.packages.default
        ];
    };
  };
}
