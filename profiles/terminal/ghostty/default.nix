{vars, ...}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {
    config,
    pkgs,
    lib,
    ...
  }: {
    programs.ghostty = {
      enable = true;
      systemd.enable = true;
      enableZshIntegration = true;

      themes = {
        catppuccin-mocha = {
          background = "1e1e2e";
          cursor-color = "f5e0dc";
          foreground = "cdd6f4";
          palette = [
            "0=#45475a"
            "1=#f38ba8"
            "2=#a6e3a1"
            "3=#f9e2af"
            "4=#89b4fa"
            "5=#f5c2e7"
            "6=#94e2d5"
            "7=#bac2de"
            "8=#585b70"
            "9=#f38ba8"
            "10=#a6e3a1"
            "11=#f9e2af"
            "12=#89b4fa"
            "13=#f5c2e7"
            "14=#94e2d5"
            "15=#a6adc8"
          ];
          selection-background = "353749";
          selection-foreground = "cdd6f4";
        };
        ayu-dark = {
          background = "0f1419";
          cursor-color = "f07178";
          foreground = "e6e1cf";
          palette = [
            "0=#000000"
            "1=#ff3333"
            "2=#86b300"
            "3=#f29718"
            "4=#41a6d6"
            "5=#a37acc"
            "6=#4dbf99"
            "7=#e8e8e8"
            "8=#323232"
            "9=#ff6565"
            "10=#b8e835"
            "11=#ffb454"
            "12=#79d8ff"
            "13=#d29fe5"
            "14=#7ff8dc"
            "15=#ffffff"
          ];
          selection-background = "333d4d";
          selection-foreground = "e6e1cf";
        };
      };
    };

    home.sessionVariables = {
      TERMINAL = lib.getExe pkgs.ghostty;
    };

    xdg.configFile."ghostty/config".source = config.lib.file.mkOutOfStoreSymlink "/home/${vars.PRIMARY_USER.NAME}/systems/profiles/terminal/ghostty/config";
  };
}
