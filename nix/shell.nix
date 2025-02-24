_: {
  perSystem = {
    config,
    self',
    inputs',
    pkgs,
    system,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        alejandra
        git
        sops
        ssh-to-age
        hcloud
      ];
    };
  };
}
