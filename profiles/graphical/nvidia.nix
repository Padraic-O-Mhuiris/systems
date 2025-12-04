{pkgs, ...}: {
  environment.systemPackages = with pkgs; [mesa-demos vulkan-tools];

  # Kernel parameters for NVIDIA PRIME
  boot.kernelParams = [
    "nvidia-drm.modeset=1" # Required for Wayland + DRM
  ];

  # Load Intel driver early in initrd so it claims displays first
  # TODO Only load in intel machines
  boot.initrd.kernelModules = ["i915"];

  # NVIDIA modules load after i915 in stage 2
  boot.kernelModules = ["nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm"];

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
        # Intel VA-API drivers for screencasting/encoding
        intel-media-driver # iHD driver for newer Intel GPUs
        intel-vaapi-driver # i965 driver for older Intel GPUs
        libvdpau-va-gl
        libva-vdpau-driver
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
