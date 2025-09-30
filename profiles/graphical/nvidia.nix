_: {
  hardware = {
    # opengl = {
    #   enable = true;
    #   driSupport32Bit = true;
    # };
    graphics = {
      enable = true;
      enable32Bit = true;
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
      forceFullCompositionPipeline = true;
    };
  };

  services.xserver.videoDrivers = ["nvidia"];
}
