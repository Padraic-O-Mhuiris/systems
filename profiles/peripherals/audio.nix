{pkgs, ...}: {
  environment.systemPackages = with pkgs; [pavucontrol pulseaudio alsa-utils];

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    socketActivation = true;
    systemWide = false;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Must set to false as conflicts with pipewire
  services.pulseaudio.enable = false;
}
