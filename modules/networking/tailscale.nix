{pkgs, ...}: {
  environment.systemPackages = [pkgs.tailscale];

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  networking.search = ["tail684cf.ts.net"];
  environment.persistence."/persist".directories = ["/var/lib/tailscale"];
}
