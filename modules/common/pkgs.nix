{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    vim
    htop
    git
    rsync
    btop
    jq
    wget
    unzip
    bc
    nautilus
    pciutils
  ];
}
