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

  home-manager.users.${vars.PRIMARY_USER.NAME} = {config, ...}: {
    home.packages = with pkgs; [
      wofi
    ];

    home.sessionVariables.NIXOS_OZONE_WL = "1";
    programs.kitty.enable = true; # required for the default Hyprland config

    wayland.windowManager.hyprland = {
      enable = true; # enable Hyprland

      settings = {
        "$mod" = "SUPER";
        input = {
          kb_layout = "gb";
          kb_options = "ctrl:nocaps";
        };
        bind =
          [
            "$mod, F, exec, firefox"
            "$mod, D, exec, wofi --show drun"
            "$mod, Return, exec, kitty" # Super+Enter to launch kitty
            "$mod, T, exec, kitty" # Alternative: Super+T to launch kitty
          ]
          ++ (
            # workspaces
            # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
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
