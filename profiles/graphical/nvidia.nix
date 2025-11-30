{pkgs, ...}: {
  environment.systemPackages = with pkgs; [mesa-demos vulkan-tools];

  # Kernel parameters for NVIDIA PRIME
  boot.kernelParams = [
    "nvidia-drm.modeset=1"  # Required for Wayland + DRM
  ];

  hardware = {
    # opengl = {
    #   enable = true;
    #   driSupport32Bit = true;
    # };
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        vulkan-loader
        vulkan-validation-layers
        nvidia-vaapi-driver
      ];
    };

    nvidia = {
      open = false;
      # package = config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting.enable = true;

      # PRIME sync: NVIDIA always active, Intel manages display
      prime.sync.enable = true;

      # Disable power management (can interfere with PRIME sync)
      powerManagement = {
        enable = false;
        finegrained = false;
      };

      # Only needed for X11 screen tearing
      forceFullCompositionPipeline = false;
    };
  };

  services.xserver.videoDrivers = ["nvidia"];
}
