{self, ...}: {
  flake = {
    inherit self;
  };

  perSystem = {
    pkgs,
    system,
    ...
  }: {
    packages = builtins.listToAttrs (
      builtins.attrValues (
        builtins.mapAttrs (host: hostCfg: {
          name = "edit${host}Secrets";
          value = pkgs.writeShellScriptBin "edit${host}Secrets" ''
            EDITOR=${pkgs.vim}/bin/vim \
            SOPS_AGE_KEY=$(${pkgs.ssh-to-age}/bin/ssh-to-age -private-key <<< $(${pkgs.pass}/bin/pass show os/users/padraic/id_ed25519)) \
            ${pkgs.sops}/bin/sops \$1
          '';
        })
        self.nixosConfigurations
      )
    );
  };
}
