_: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    #     terranix.terranixConfigurations = {
    #       Carbon = {
    #         modules = [
    #           (_: {
    #             terraform.required_providers.hcloud = {
    #               source = "hetznercloud/hcloud";
    #               version = "~> 1.45";
    #             };

    #             provider.hcloud = {
    #               token = "\${var.hcloud_token}";
    #             };
    #             variable = {
    #               hcloud_token = {
    #                 description = "Hetzner Cloud API Token";
    #                 type = "string";
    #                 sensitive = true;
    #               };

    #               hcloud_ssh_key = {
    #                 description = "Hetzner Cloud API Token";
    #                 type = "string";
    #                 sensitive = true;
    #               };

    #               cluster_name = {
    #                 description = "Name prefix for the cluster";
    #                 type = "string";
    #                 default = "k8s";
    #               };

    #               master_server_type = {
    #                 description = "Server type for master node";
    #                 type = "string";
    #                 default = "cx22"; # 2 vCPU, 8GB RAM
    #               };

    #               worker_server_type = {
    #                 description = "Server type for worker nodes";
    #                 type = "string";
    #                 default = "cx21"; # 2 vCPU, 4GB RAM
    #               };

    #               location = {
    #                 description = "Server location";
    #                 type = "string";
    #                 default = "nbg1";
    #               };

    #               base_image = {
    #                 description = "Base image for nixos-anywhere";
    #                 type = "string";
    #                 default = "ubuntu-22.04";
    #               };
    #             };
    #           })
    #         ];
    #         workdir = "\"$PRJ_ROOT/hosts/Carbon/.tf\"";
    #       };
    #     };
  };
}
