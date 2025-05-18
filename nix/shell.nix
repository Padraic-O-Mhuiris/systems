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
          git
          hcloud
          just
        ]
        ++ [
          inputs'.nixos-anywhere.packages.default
        ];
    };
  };
}
