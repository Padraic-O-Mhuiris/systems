{
  pkgs,
  vars,
  ...
}: {
  imports = [./bars/waybar.nix];

  programs.hyprland = {
    enable = true;
  };

  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    defaultSession = "hyprland";
  };

  home-manager.users.${vars.PRIMARY_USER.NAME} = {
    config,
    lib,
    ...
  }: {
    home.packages = with pkgs; [
      wofi
    ];
    home.sessionVariables = {
      "LAUNCHER" = "${lib.getExe config.programs.wofi.package}/bin/wofi --show drun -I";
      NIXOS_OZONE_WL = "1";
    };

    wayland.windowManager.hyprland = {
      enable = true;

      settings = {
        "$mod" = "SUPER";
        input = {
          kb_layout = "gb";
          kb_options = "ctrl:nocaps";
        };
        bind =
          [
            "$mod SHIFT, E, exec, pkill Hyprland"
            "$mod, q, killactive,"
            "$mod, f, fullscreen,"
            "$mod, d, exec, ${config.home.sessionVariables.LAUNCHER}"
            "$mod, x, exec, hdrop ${config.home.sessionVariables.TERMINAL}"
          ]
          ++ (
            builtins.concatLists (builtins.genList (
                i: let
                  ws = i + 1;
                in [
                  "$mod, code:1${toString i}, workspace, ${toString ws}"
                  "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
                ]
              )
              9)
          );
        exec-once = [
          "waybar"
        ];
      };
    };
  };
}
