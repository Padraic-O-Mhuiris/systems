{
  pkgs,
  lib,
  vars,
  ...
}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {config, ...}: {
    xdg.configFile = let
      helixSrcPath = "/home/${vars.PRIMARY_USER.NAME}/systems/profiles/editors/helix";
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
    };

    programs.helix = {
      enable = true;
      defaultEditor = true;
      extraPackages = with pkgs; [
        nil
        nixd
        nodePackages.bash-language-server
        nodePackages.typescript-language-server
        llvmPackages_20.clang-tools
        ruff
        pyright
        lazygit

        stylua
        lua-language-server

        nixfmt-rfc-style
        lldb_18
        taplo

        shfmt

        # markdown
        marksman
        ltex-ls-plus
        mpls
      ];
    };
  };
}
