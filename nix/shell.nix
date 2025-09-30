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
        ]
        ++ [
          inputs'.nixos-anywhere.packages.default
          inputs'.terranix.packages.default
          inputs'.nixidy.packages.default
        ];
    };
  };
}
