{lib, ...}: {
  applications.l1 = {
    namespace = "l1";

    # Automatically generate a namespace resource with the
    # above set namespace
    createNamespace = true;

    helm.releases.l1 = {
      chart = lib.helm.downloadHelmChart {
        repo = "https://ethpandaops.github.io/ethereum-helm-charts/";
        chart = "ethereum-node";
        version = "0.2.4";
        chartHash = "sha256-WcqjsPuivBAbEMFF9Qb8KUPRBBfWy7hhErutrlxPfx0=";
      };
      values = rec {
        global = {
          network = "mainnet";
          checkpointSync = {
            enabled = true;
            networks = {
              mainnet = "https://mainnet-checkpoint-sync.attestant.io";
              sepolia = "https://checkpoint-sync.sepolia.ethpandaops.io";
              holesky = "https://checkpoint-sync.holesky.ethpandaops.io";
              hoodi = "https://checkpoint-sync.hoodi.ethpandaops.io";
            };
          };
        };

        geth = {
          enabled = true;
          nameOverride = "execution";
          httpPort = 8545;
          wsPort = 8546;
          p2pPort = 30303;
          extraArgs = [
            "--${global.network}"
          ];
        };

        lighthouse = {
          enabled = true;
          nameOverride = "beacon";
          httpPort = 5052;
          p2pPort = 9000;
          checkpointSync = {
            enabled = global.checkpointSync.enabled;
            url = global.checkpointSync.networks.${global.network};
          };
          extraArgs = [
            "--execution-endpoint=http://l1-execution:8551"
            "--network=${global.network}"
          ];
        };
      };
    };
  };
}
