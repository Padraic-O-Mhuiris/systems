{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    vim
    tree
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
