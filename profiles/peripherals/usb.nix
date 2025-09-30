_: {
  services.udisks2 = {
    enable = true;
    mountOnMedia = true;
  };

  programs.gnome-disks.enable = true;
}
