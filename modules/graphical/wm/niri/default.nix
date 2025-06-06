{
  pkgs,
  inputs,
  vars,
  ...
}: {
  # imports = [inputs.niri.nixosModules.niri];

  programs.niri.enable = true;
  # nixpkgs.overlays = [inputs.niri.overlays.niri];
  # programs.niri.package = pkgs.niri-unstable;

  # environment.variables.NIXOS_OZONE_WL = "1";
  # environment.systemPackages = with pkgs; [
  #   wl-clipboard
  #   wayland-utils
  #   libsecret
  #   cage
  #   gamescope
  #   xwayland-satellite-unstable
  #   swaybg
  # ];

  home-manager.users.${vars.PRIMARY_USER.NAME} = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [inputs.niri.homeModules.niri];

    home.sessionVariables = {
      LAUNCHER = "${lib.getExe pkgs.fuzzel}";
    };
    xdg.configFile = {
      "niri/config.kdl".text =
        # kdl
        ''
          input {
              keyboard {
                  xkb {
                      layout "gb"
                      options "ctrl:nocaps"
                  }
              }
          }

          output "DP-1" {
              scale 1.0
              mode "5120x1440@99.996"
              focus-at-startup
              position x=1920 y=0
          }

          // Laptop screen
          output "HDMI-A-1" {
              scale 1.0
              mode "1920x1080@60"
              position x=0 y=0
          }

          binds {
              Mod+D { spawn "${config.home.sessionVariables.LAUNCHER}"; }
              Mod+X { spawn "${config.home.sessionVariables.TERMINAL}"; }

              Mod+1 { focus-workspace 1; }
              Mod+2 { focus-workspace 2; }
              Mod+3 { focus-workspace 3; }
              Mod+4 { focus-workspace 4; }
              Mod+5 { focus-workspace 5; }
              Mod+6 { focus-workspace 6; }
              Mod+7 { focus-workspace 7; }
              Mod+8 { focus-workspace 8; }
              Mod+9 { focus-workspace 9; }

              Mod+Shift+1 { move-column-to-workspace 1; }
              Mod+Shift+2 { move-column-to-workspace 2; }
              Mod+Shift+3 { move-column-to-workspace 3; }
              Mod+Shift+4 { move-column-to-workspace 4; }
              Mod+Shift+5 { move-column-to-workspace 5; }
              Mod+Shift+6 { move-column-to-workspace 6; }
              Mod+Shift+7 { move-column-to-workspace 7; }
              Mod+Shift+8 { move-column-to-workspace 8; }
              Mod+Shift+9 { move-column-to-workspace 9; }

              Mod+Down      { focus-workspace-down; }
              Mod+Up        { focus-workspace-up; }
              // Mod+Shift+Page_Down { move-column-to-workspace-down; }
              // Mod+Shift+Page_Up   { move-column-to-workspace-up; }

              Mod+Shift+Left  { move-column-left; }
              Mod+Shift+Down  { move-window-down; }
              Mod+Shift+Up    { move-window-up; }
              Mod+Shift+Right { move-column-right; }

              Mod+Q { close-window; }
              Mod+F { maximize-column; }
              Mod+Shift+F { fullscreen-window; }
          };
        '';
    };

    # programs.niri.settings = {
    #   binds = {
    #     "Mod+D".action.spawn = "${config.home.sessionVariables.LAUNCHER}";
    #     "Mod+X".action.spawn = "${config.home.sessionVariables.TERMINAL}";
    #   };
    # };
  };
}
