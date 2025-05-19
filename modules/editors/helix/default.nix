{
  pkgs,
  lib,
  vars,
  ...
}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {config, ...}: {
    xdg.configFile = {
      "helix/config.toml".source = lib.mkForce (
        config.lib.file.mkOutOfStoreSymlink "/home/padraic/code/nix/padraic.nix/home/editors/helix/config.toml"
      );
      "helix/languages.toml".source = lib.mkForce (
        config.lib.file.mkOutOfStoreSymlink "/home/padraic/code/nix/padraic.nix/home/editors/helix/languages.toml"
      );
      "helix/ignore".source = lib.mkForce (
        config.lib.file.mkOutOfStoreSymlink "/home/padraic/code/nix/padraic.nix/home/editors/helix/ignore"
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
        marksman
        mdformat
        nixfmt-rfc-style
        lldb_18
        taplo
      ];
    };
  };
}
