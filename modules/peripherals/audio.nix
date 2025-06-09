{pkgs, ...}: {
  environment.systemPackages = with pkgs; [pavucontrol];

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    socketActivation = true;
    systemWide = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Must set to false as conflicts with pipewire
  hardware.pulseaudio.enable = false;
}
