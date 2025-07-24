{
  pkgs,
  lib,
  vars,
  ...
}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {config, ...}: {
    xdg.configFile = let
      helixSrcPath = "/home/${vars.PRIMARY_USER.NAME}/systems/modules/editors/helix";
    in {
      "helix/config.toml".source = lib.mkForce (
        config.lib.file.mkOutOfStoreSymlink "${helixSrcPath}/config/helix/config.toml"
      );
      "helix/languages.toml".source = lib.mkForce (
        config.lib.file.mkOutOfStoreSymlink "${helixSrcPath}/config/helix/languages.toml"
      );
      "helix/ignore".source = lib.mkForce (
        config.lib.file.mkOutOfStoreSymlink "${helixSrcPath}/config/helix/ignore"
      );
      "dprint/config.json".source = lib.mkForce (
        config.lib.file.mkOutOfStoreSymlink "${helixSrcPath}/config/dprint/config.json"
      );
    };

    programs.helix = {
      enable = true;
      defaultEditor = true;
      extraPackages = with pkgs; [
        nil
        nixd
        nodePackages.bash-language-server
        nodePackages.typescript-language-server
        lua-language-server
        llvmPackages_17.clang-tools
        ruff
        pyright
        lazygit
        luaformatter

        nixfmt-rfc-style
        lldb_18
        taplo
        gopls
        golangci-lint-langserver
        golangci-lint

        # markdown
        marksman
        dprint
      ];
    };
  };
}
