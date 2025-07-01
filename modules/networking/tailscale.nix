{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = [pkgs.tailscale];

  sops.secrets.tailscale_auth = {};

  services.tailscale = {
    enable = true;
    permitCertUid = "patrick.morris.310@gmail.com";
    openFirewall = true;
    authKeyFile = config.sops.secrets.tailscale_auth.path;
  };

  networking.search = ["tail684cf.ts.net"];
  environment.persistence."/persist".directories = ["/var/lib/tailscale"];
}
