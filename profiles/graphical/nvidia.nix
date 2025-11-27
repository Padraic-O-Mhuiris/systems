{pkgs, ...}: {
  environment.systemPackages = with pkgs; [mesa-demos vulkan-tools];
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
      ];
    };

    nvidia = {
      open = false;
      # package = config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting.enable = true;
      prime = {
        sync.enable = true;
        nvidiaBusId = "PCI:9:0:0";
        amdgpuBusId = "PCI:0:2:0";
      };
      # Only needed for X11 screen tearing
      forceFullCompositionPipeline = false;
    };
  };

  services.xserver.videoDrivers = ["nvidia"];
}
