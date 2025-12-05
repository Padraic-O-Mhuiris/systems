{vars, ...}: {
  home-manager.users.${vars.users.primary.name} = {pkgs, ...}: {
    home.packages = [
      pkgs.libnotify
    ];

    services.mako = {
      enable = true;
      settings = {
        # Positioning
        anchor = "top-right";
        layer = "overlay";
        max-visible = 5;

        # Appearance
        width = 400;
        height = 150;
        border-radius = 8;
        border-size = 2;
        padding = 12;
        margin = 10;

        # Colors (dark theme with subtle accents)
        background-color = "#1e1e2edd";
        text-color = "#cdd6f4";
        border-color = "#89b4fa";

        # Typography
        font = "sans-serif 11";
        text-alignment = "left";

        # Icons
        icons = 1;
        max-icon-size = 48;
        icon-location = "left";

        # Behavior
        default-timeout = 5000;  # 5 seconds
        ignore-timeout = 0;
        history = 1;
        max-history = 10;
        sort = "-time";

        # Actions
        actions = 1;
        on-button-right = "dismiss";
        on-button-middle = "invoke-default-action";
      };
    };
  };
}
