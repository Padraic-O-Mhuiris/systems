{
  lib,
  stdenv,
  makeWrapper,
  bashInteractive,
  bubblewrap,
  buildEnv,
  git,
  ripgrep,
  fd,
  coreutils,
  gnugrep,
  gnused,
  gawk,
  findutils,
  which,
  tree,
  curl,
  wget,
  jq,
  less,
  zsh,
  nix,
  claude,
}: let
  # Bundle all the tools Claude needs into a single environment
  claudeTools = buildEnv {
    name = "claude-tools";
    paths = [
      # main claude binary
      claude
      # Essential tools Claude commonly uses
      git
      ripgrep
      fd
      coreutils
      gnugrep
      gnused
      gawk
      findutils
      which
      tree
      curl
      wget
      jq
      less
      # Shells
      zsh
      # Nix is essential for nix run
      nix
    ];
  };
in
  stdenv.mkDerivation {
    pname = "cc";
    version = "0.0.0";

    src = ./.;

    nativeBuildInputs = [makeWrapper];

    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/share

      # Install helper scripts
      cp ${./cc.sh} $out/bin/cc
      chmod +x $out/bin/cc

      # Patch shebang
      patchShebangs $out/bin/cc

      # Wrap cc start script
      wrapProgram $out/bin/cc \
        --prefix PATH : ${lib.makeBinPath [
        bashInteractive
        bubblewrap
        claudeTools
      ]}

      runHook postInstall
    '';

    meta = with lib; {
      description = "Sandboxed environment for Claude Code";
      sourceProvenance = with sourceTypes; [fromSource];
      platforms = platforms.linux;
      mainProgram = "cc";
    };
  }
