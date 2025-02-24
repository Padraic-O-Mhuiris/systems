{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        alejandra
        inputs.nixos-anywhere.packages.${pkgs.system}.default
        git
        sops
        ssh-to-age
        hcloud
      ];
    };
  };
}
