{
  vars,
  pkgs,
  ...
}: let
  # TODO Add to vars
  SSH_PORT = 22;
in {
  users.users = {
    ${vars.PRIMARY_USER.NAME} = {
      openssh.authorizedKeys.keys = [
        vars.PRIMARY_USER.SSH_PUBLIC_KEY
      ];
    };
    # TODO Perhaps access to root should be always avoided
    root = {
      openssh.authorizedKeys.keys = [
        vars.PRIMARY_USER.SSH_PUBLIC_KEY
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [SSH_PORT];

  services = {
    openssh = {
      enable = true;
      ports = [SSH_PORT];
      allowSFTP = false;

      # NOTE When using the nixos-anywhere bootstrap, the host key defined below
      # ought to already exist. The default configuration includes a ed25519 and
      # rsa key which is avoided here
      hostKeys = [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];

      settings = {
        PasswordAuthentication = false;
        AllowTcpForwarding = true;
        AllowAgentForwarding = true;
        UsePAM = true;
        X11Forwarding = false;
        KbdInteractiveAuthentication = false;
        UseDns = false;
        StreamLocalBindUnlink = "yes";
        AuthorizedKeysFile = "/etc/ssh/authorized_keys.d/%u %h/.ssh/authorized_keys";
        KexAlgorithms = [
          "curve25519-sha256"
          "curve25519-sha256@libssh.org"
          "diffie-hellman-group16-sha512"
          "diffie-hellman-group18-sha512"
          "sntrup761x25519-sha512@openssh.com"
        ];
      };
    };
  };

  systemd.services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];

  programs.ssh = {
    extraConfig = ''
      Host mac02.numtide.com
        IdentityFile /etc/ssh/ssh_host_ed25519_key
        User customer
    '';

    knownHosts = {
      "mac02.numtide.com" = {
        hostNames = ["mac02.numtide.com"];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGX2wsoPj5j08Uuzt0AF5gA6lPiZS6fU3gKSf9XMcoXd";
      };
      "github.com" = {
        hostNames = ["github.com"];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      };
      "gitlab.com" = {
        hostNames = ["gitlab.com"];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";
      };
      "git.sr.ht" = {
        hostNames = ["git.sr.ht"];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZvRd4EtM7R+IHVMWmDkVU3VLQTSwQDSAvW0t2Tkj60";
      };
    };
  };

  home-manager.users.${vars.PRIMARY_USER.NAME} = _: {
    services.ssh-agent.enable = true;

    programs.ssh = {
      enable = true;
      matchBlocks = {
        "mac02.numtide.com" = {
          host = "mac02.numtide.com";
          user = "customer";
        };
      };
    };
  };
}
