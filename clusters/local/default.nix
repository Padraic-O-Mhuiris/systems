{
  self,
  inputs,
  lib,
  ...
}: {
  # We define this to have access to the config in the repl
  flake = let
    # cluster =
    #   (inputs.nixidy.lib.mkEnv {
    #     inherit modules;
    #     pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
    #   }).config;
  in {
    # inherit cluster;

    # mkCluster = {settingsPath ? ../.obol-config.json}: let
    #   clusterEnv = inputs.nixidy.lib.mkEnv {
    #     pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
    #     modules =
    #       modules
    #       ++ [
    #         ({lib, ...}: {
    #           options.obol-stack = {
    #             settings = lib.mkOption {
    #               type = lib.types.attrsOf lib.types.anything;
    #               default = builtins.fromJSON (builtins.readFile settingsPath);
    #             };
    #           };
    #         })
    #       ];
    #   };
    # in {
    #   clusterActivation = clusterEnv.activationPackage;
    #   clusterBootstrap = clusterEnv.bootstrapPackage;
    #   clusterDeclarative = clusterEnv.declarativePackage;
    #   clusterEnvironment = clusterEnv.environmentPackage;
    # };
  };

  # perSystem = {pkgs, ...}: let
  #   # cluster = inputs.nixidy.lib.mkEnv {
  #   #   inherit pkgs modules;
  #   # };
  # in {
  #   # TODO It would be nice to define these as their own transposition
  #   packages = rec {
  #     # clusterActivation = cluster.activationPackage;
  #     # clusterBootstrap = cluster.bootstrapPackage;
  #     # clusterDeclarative = cluster.declarativePackage;
  #     # clusterEnvironment = cluster.environmentPackage;

  #     # default = clusterActivation;
  #   };
  # };
}
#    let
#   eachSystem = lib.genAttrs (builtins.attrNames self.packages);
# in {
#   flake = {
#     nixidyEnvs = eachSystem (system: let
#       pkgs = inputs.nixpkgs.legacyPackages.${system};
#     in {
#       local = inputs.nixidy.lib.mkEnv {
#         inherit pkgs;
#         modules = [
#           ./demo
#           ./l1
#           # nixidy specific settings
#           {
#             nixidy = {
#               target = {
#                 repository = "https://github.com/Padraic-O-Mhuiris/systems";
#                 branch = "master";
#                 rootPath = "./clusters/local/manifests";
#               };
#               build.revision =
#                 if (self ? rev)
#                 then self.rev
#                 else self.dirtyRev;
#             };
#           }
#         ];
#       };
#     });
#   };
# }

