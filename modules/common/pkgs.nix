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
    pciutils
    ripgrep
    fzf
    entr
    ffmpeg
  ];
}
