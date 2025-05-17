_: {
  perSystem = {
    inputs',
    pkgs,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      packages = with pkgs;
        [
          alejandra
          # inputs.nixos-anywhere.packages.${pkgs.system}.default
          git
          hcloud
          just
        ]
        ++ [
          inputs'.nixos-anywhere.packages.default
          inputs'.clan.packages.clan-cli
        ];
    };
  };
}
