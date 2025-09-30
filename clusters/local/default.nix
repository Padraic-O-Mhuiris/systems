{
  self,
  inputs,
  lib,
  ...
}: let
  eachSystem = lib.genAttrs (builtins.attrNames self.allSystems);
in {
  flake = {
    nixidyEnvs = eachSystem (system: let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    in {
      local = inputs.nixidy.lib.mkEnv {
        inherit pkgs;
        modules = [
          {
            nixidy = {
              target = {
                repository = "https://github.com/Padraic-O-Mhuiris/systems";
                branch = "master";
                rootPath = "./clusters/local/manifests";
              };
              # applicationImports = [
              #   ../../crds/external-secrets.io.v1.ExternalSecret
              # ];
              extraFiles = {};
            };
          }

          # httpbin
          # ({...}: {
          #   applications.httpbin = {
          #     namespace = "httpbin";
          #     createNamespace = true;
          #     resources = let
          #       labels = {
          #         "app.kubernetes.io/name" = "httpbin";
          #       };
          #     in {
          #       deployments.httpbin.spec = {
          #         selector.matchLabels = labels;
          #         template = {
          #           metadata.labels = labels;
          #           spec = {
          #             containers.httpbin = {
          #               image = "mccutchen/go-httpbin:v2.15.0";
          #             };
          #           };
          #         };
          #       };
          #       services.httpbin-svc = {
          #         spec = {
          #           selector = labels;
          #           ports.http = {
          #             port = 80;
          #             appProtocol = "http";
          #             targetPort = 8080;
          #           };
          #         };
          #       };
          #     };
          #   };
          # })

          # ({lib, ...}: {
          #   applications.kong = {
          #     namespace = "kong";
          #     createNamespace = true;
          #     resources = {
          #       services.kong-gateway-proxy.metadata.annotations."metallb.universe.tf/loadBalancerIPs" = "192.168.18.150";
          #     };

          #     helm.releases.kong = {
          #       chart = lib.helm.downloadHelmChart {
          #         repo = "https://charts.konghq.com";
          #         chart = "ingress";
          #         version = "0.20.0";
          #         chartHash = "sha256-it5oEOcZ8AEV6fGrKlmSUwn00l7yD13mIRraWXnHCdA=";
          #       };
          #       values = {
          #         gateway = {
          #           image.tag = "3.10";
          #           image.repository = "kong/kong-gateway";
          #           admin.http.enabled = true;
          #           env.router_flavor = "expressions";
          #         };
          #       };
          #       transformer = map (
          #         lib.kube.removeLabels [
          #           "app.kubernetes.io/version"
          #           "helm.sh/chart"
          #         ]
          #       );
          #       extraOpts = [
          #         "--api-versions"
          #         "gateway.networking.k8s.io/v1"
          #       ];
          #     };
          #   };
          # })

          # https://github.com/arnarg/cluster/blob/145380a8e7a42ec18acbf6295566924563733de5/flake.nix#L36C9-L41C10
          {
            nixidy.build.revision =
              if (self ? rev)
              then self.rev
              else self.dirtyRev;
          }
        ];
      };
    });
  };
}
