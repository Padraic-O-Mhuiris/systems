{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.claude-box;
  jsonFormat = pkgs.formats.json {};
in {
  options.programs.claude-box = {
    enable = lib.mkEnableOption "Claude Code, Anthropic's official CLI";

    package = lib.mkPackageOption pkgs "claude-code" {nullable = true;};

    finalPackage = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      internal = true;
      description = "Resulting customized claude-code package.";
    };

    apiKeyPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };

    settings = lib.mkOption {
      inherit (jsonFormat) type;
      default = {};
      example = {
        theme = "dark";
        permissions = {
          allow = [
            "Bash(git diff:*)"
            "Edit"
          ];
          ask = ["Bash(git push:*)"];
          deny = [
            "WebFetch"
            "Bash(curl:*)"
            "Read(./.env)"
            "Read(./secrets/**)"
          ];
          additionalDirectories = ["../docs/"];
          defaultMode = "acceptEdits";
          disableBypassPermissionsMode = "disable";
        };
        model = "claude-3-5-sonnet-20241022";
        hooks = {
          PreToolUse = [
            {
              matcher = "Bash";
              hooks = [
                {
                  type = "command";
                  command = "echo 'Running command: $CLAUDE_TOOL_INPUT'";
                }
              ];
            }
          ];
          PostToolUse = [
            {
              matcher = "Edit|MultiEdit|Write";
              hooks = [
                {
                  type = "command";
                  command = "nix fmt $(jq -r '.tool_input.file_path' <<< '$CLAUDE_TOOL_INPUT')";
                }
              ];
            }
          ];
        };
        statusLine = {
          type = "command";
          command = "input=$(cat); echo \"[$(echo \"$input\" | jq -r '.model.display_name')] 📁 $(basename \"$(echo \"$input\" | jq -r '.workspace.current_dir')\")\"";
          padding = 0;
        };
        includeCoAuthoredBy = false;
      };
      description = "JSON configuration for Claude Code settings.json";
    };

    agents = lib.mkOption {
      type = lib.types.attrsOf (lib.types.either lib.types.lines lib.types.path);
      default = {};
      description = ''
        Custom agents for Claude Code.
        The attribute name becomes the agent filename, and the value is either:
        - Inline content as a string with frontmatter
        - A path to a file containing the agent content with frontmatter
        Agents are stored in .claude/agents/ directory.
      '';
      example = lib.literalExpression ''
        {
          code-reviewer = '''
            ---
            name: code-reviewer
            description: Specialized code review agent
            tools: Read, Edit, Grep
            ---

            You are a senior software engineer specializing in code reviews.
            Focus on code quality, security, and maintainability.
          ''';
          documentation = ./agents/documentation.md;
        }
      '';
    };

    commands = lib.mkOption {
      type = lib.types.attrsOf (lib.types.either lib.types.lines lib.types.path);
      default = {};
      description = ''
        Custom commands for Claude Code.
        The attribute name becomes the command filename, and the value is either:
        - Inline content as a string
        - A path to a file containing the command content
        Commands are stored in .claude/commands/ directory.
      '';
      example = lib.literalExpression ''
        {
          changelog = '''
            ---
            allowed-tools: Bash(git log:*), Bash(git diff:*)
            argument-hint: [version] [change-type] [message]
            description: Update CHANGELOG.md with new entry
            ---
            Parse the version, change type, and message from the input
            and update the CHANGELOG.md file accordingly.
          ''';
          fix-issue = ./commands/fix-issue.md;
          commit = '''
            ---
            allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*)
            description: Create a git commit with proper message
            ---
            ## Context

            - Current git status: !`git status`
            - Current git diff: !`git diff HEAD`
            - Recent commits: !`git log --oneline -5`

            ## Task

            Based on the changes above, create a single atomic git commit with a descriptive message.
          ''';
        }
      '';
    };

    hooks = lib.mkOption {
      type = lib.types.attrsOf lib.types.lines;
      default = {};
      description = ''
        Custom hooks for Claude Code.
        The attribute name becomes the hook filename, and the value is the hook script content.
        Hooks are stored in .claude/hooks/ directory.
      '';
      example = {
        pre-edit = ''
          #!/usr/bin/env bash
          echo "About to edit file: $1"
        '';
        post-commit = ''
          #!/usr/bin/env bash
          echo "Committed with message: $1"
        '';
      };
    };

    memory = {
      text = lib.mkOption {
        type = lib.types.nullOr lib.types.lines;
        default = null;
        description = ''
          Inline memory content for CLAUDE.md.
          This option is mutually exclusive with memory.source.
        '';
        example = ''
          # Project Memory

          ## Current Task
          Implementing enhanced claude-code module for home-manager.

          ## Key Files
          - claude-code.nix: Main module implementation
        '';
      };

      source = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = ''
          Path to a file containing memory content for CLAUDE.md.
          This option is mutually exclusive with memory.text.
        '';
        example = lib.literalExpression "./claude-memory.md";
      };
    };

    agentsDir = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to a directory containing agent files for Claude Code.
        Agent files from this directory will be symlinked to .claude/agents/.
      '';
      example = lib.literalExpression "./agents";
    };

    commandsDir = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to a directory containing command files for Claude Code.
        Command files from this directory will be symlinked to .claude/commands/.
      '';
      example = lib.literalExpression "./commands";
    };

    hooksDir = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to a directory containing hook files for Claude Code.
        Hook files from this directory will be symlinked to .claude/hooks/.
      '';
      example = lib.literalExpression "./hooks";
    };

    mcpServers = lib.mkOption {
      type = lib.types.attrsOf jsonFormat.type;
      default = {};
      description = "MCP (Model Context Protocol) servers configuration";
      example = {
        github = {
          type = "http";
          url = "https://api.githubcopilot.com/mcp/";
        };
        filesystem = {
          type = "stdio";
          command = "npx";
          args = [
            "-y"
            "@modelcontextprotocol/server-filesystem"
            "/tmp"
          ];
        };
        database = {
          type = "stdio";
          command = "npx";
          args = [
            "-y"
            "@bytebase/dbhub"
            "--dsn"
            "postgresql://user:pass@localhost:5432/db"
          ];
          env = {
            DATABASE_URL = "postgresql://user:pass@localhost:5432/db";
          };
        };
        customTransport = {
          type = "websocket";
          url = "wss://example.com/mcp";
          customOption = "value";
          timeout = 5000;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.mcpServers == {} || cfg.package != null;
        message = "`programs.claude-code.package` cannot be null when `mcpServers` is configured";
      }
      {
        assertion = !(cfg.memory.text != null && cfg.memory.source != null);
        message = "Cannot specify both `programs.claude-code.memory.text` and `programs.claude-code.memory.source`";
      }
      {
        assertion = !(cfg.agents != {} && cfg.agentsDir != null);
        message = "Cannot specify both `programs.claude-code.agents` and `programs.claude-code.agentsDir`";
      }
      {
        assertion = !(cfg.commands != {} && cfg.commandsDir != null);
        message = "Cannot specify both `programs.claude-code.commands` and `programs.claude-code.commandsDir`";
      }
      {
        assertion = !(cfg.hooks != {} && cfg.hooksDir != null);
        message = "Cannot specify both `programs.claude-code.hooks` and `programs.claude-code.hooksDir`";
      }
    ];

    programs.claude-box.finalPackage = let
      makeWrapperArgs = lib.flatten (
        lib.filter (x: x != []) [
          [
            "--add-flags"
            "--dangerously-skip-permissions"
          ]
          (lib.optional (cfg.mcpServers != {}) [
            "--add-flags"
            "--mcp-config ${jsonFormat.generate "claude-code-mcp-config.json" {inherit (cfg) mcpServers;}}"
          ])
        ]
      );

      hasWrapperArgs = makeWrapperArgs != [];

      wrappedClaudePkg =
        if hasWrapperArgs
        then
          pkgs.symlinkJoin {
            name = "claude-code";
            paths = [cfg.package];
            nativeBuildInputs = [pkgs.makeWrapper];
            postBuild = ''
              wrapProgram $out/bin/claude ${lib.escapeShellArgs makeWrapperArgs}
            '';
            inherit (cfg.package) meta;
          }
        else cfg.package;

      claude-box = pkgs.writeShellApplication {
        name = "claude-box";
        text = ''
          set -euo pipefail

          # cc - Run Claude Code in YOLO mode with transparency
          # Shows all commands Claude executes in a tmux split pane

          # Generate unique session name for this sandbox
          project_dir="$(pwd)"

          # Try to find git repo root, fallback to current directory
          repo_root="$(git rev-parse --show-toplevel 2>/dev/null || echo "$project_dir")"

          session_prefix="$(basename "$repo_root")"
          session_id="$(printf '%04x%04x' $RANDOM $RANDOM)"
          session_name="''${session_prefix}-''${session_id}"

          # Create isolated home directory (protects real home from YOLO mode)
          claude_home="/tmp/''${session_name}"
          at_exit() {
            rm -rf "$claude_home"
          }
          trap at_exit EXIT
          mkdir -p "$claude_home"

          # Mount points for Claude config (needs API keys)
          claude_config="''${HOME}/.claude"
          claude_api_secret="''${HOME}/.claude_api_secret"
          mkdir -p "$claude_config"
          claude_json="''${HOME}/.claude.json"

          # Ensure Claude is initialized before sandboxing
          if [[ ! -f $claude_json ]]; then
            echo "Initializing Claude configuration..."
            claude --help >/dev/null 2>&1 || true
            sleep 1
          fi

          # Smart filesystem sharing - full tree read-only, repo/project read-write
          real_repo_root="$(realpath "$repo_root")"
          real_home="$(realpath "$HOME")"

          if [[ $real_repo_root == "$real_home"/* ]]; then
            # Share entire top-level directory as read-only (e.g., ~/projects/*)
            rel_path="''${real_repo_root#"$real_home"/}"
            top_dir="$(echo "$rel_path" | cut -d'/' -f1)"
            share_tree="$real_home/$top_dir"
          else
            # Only share current repo/project directory
            share_tree="$real_repo_root"
          fi

          # Bubblewrap sandbox - lightweight isolation for transparency
          bwrap_args=(
            --dev /dev
            --proc /proc
            --ro-bind /usr /usr
            --ro-bind /bin /bin
            # --ro-bind /lib /lib
            --ro-bind /lib64 /lib64
            --ro-bind /etc /etc
            --ro-bind /nix /nix
            --bind /nix/var/nix/daemon-socket /nix/var/nix/daemon-socket # For package installs
            --tmpfs /tmp
            --bind "$claude_home" "$HOME"           # Isolated home (YOLO safety)
            --bind "$claude_config" "$HOME/.claude" # API keys access, would be better to have this externally accessible but for now the browser login is most reliable
            --bind "$claude_json" "$HOME/.claude.json"
            --unshare-all
            --share-net
            --ro-bind /run /run
            --setenv HOME "$HOME"
            --setenv SESSION_NAME "$session_name"
            --setenv USER "$USER"
            --setenv PATH "$PATH"
            --setenv TMUX_TMPDIR "/tmp"
            --setenv TMPDIR "/tmp"
            --setenv TEMPDIR "/tmp"
            --setenv TEMP "/tmp"
            --setenv TMP "/tmp"
          )
          ${lib.optionalString (cfg.apiKeyPath != null) ''
            bwrap_args+=(
              --bind ${cfg.apiKeyPath} "$claude_api_secret"
            )
          ''}

          # Mount parent directory tree if working under home
          if [[ $share_tree != "$repo_root" ]]; then
            bwrap_args+=(--ro-bind "$share_tree" "$share_tree")
          fi

          # Git repo root (or current dir) gets full write access (YOLO mode)
          bwrap_args+=(--bind "$repo_root" "$repo_root")

          # Define log file path
          logfile="/tmp/claudebox-commands-''${session_name}.log"

          # Add logfile to bwrap environment
          bwrap_args+=(--setenv CLAUDEBOX_LOG_FILE "$logfile")

          # Launch tmux with Claude in left pane, commands in right
          bwrap "''${bwrap_args[@]}" bash -c "
            # Change to original working directory
            cd '$project_dir'

            # Create the log file
            touch '$logfile'

            exec ${lib.getExe wrappedClaudePkg}
          "
        '';
      };
      claudeTools = pkgs.buildEnv {
        name = "claude-tools";
        paths = with pkgs; [
          cfg.package
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
      pkgs.runCommand "claude-box-wrapped" {
        buildInputs = [pkgs.makeWrapper];
      } ''
        mkdir -p $out/bin
        cp ${lib.getExe claude-box} $out/bin
        chmod +x $out/bin/claude-box
        patchShebangs $out/bin/claude-box
        wrapProgram $out/bin/claude-box \
          --prefix PATH : ${
          pkgs.lib.makeBinPath [
            pkgs.bashInteractive
            pkgs.bubblewrap
            pkgs.tmux
            claudeTools
          ]
        }
      '';

    home = {
      packages = lib.mkIf (cfg.package != null) [cfg.finalPackage cfg.package];

      file =
        {
          ".claude/settings.json" = lib.mkIf (cfg.settings != {} || cfg.apiKeyPath != null) {
            source = jsonFormat.generate "claude-code-settings.json" (
              cfg.settings
              // (lib.optionalAttrs (cfg.apiKeyPath != null) {apiKeyPath = "cat ~/.claude_api_secret";})
            );
          };

          ".claude/CLAUDE.md" = lib.mkIf (cfg.memory.text != null || cfg.memory.source != null) (
            if cfg.memory.text != null
            then {text = cfg.memory.text;}
            else {source = cfg.memory.source;}
          );

          ".claude/agents" = lib.mkIf (cfg.agentsDir != null) {
            source = cfg.agentsDir;
            recursive = true;
          };

          ".claude/commands" = lib.mkIf (cfg.commandsDir != null) {
            source = cfg.commandsDir;
            recursive = true;
          };

          ".claude/hooks" = lib.mkIf (cfg.hooksDir != null) {
            source = cfg.hooksDir;
            recursive = true;
          };
        }
        // lib.mapAttrs' (
          name: content:
            lib.nameValuePair ".claude/agents/${name}.md" (
              if lib.isPath content
              then {source = content;}
              else {text = content;}
            )
        )
        cfg.agents
        // lib.mapAttrs' (
          name: content:
            lib.nameValuePair ".claude/commands/${name}.md" (
              if lib.isPath content
              then {source = content;}
              else {text = content;}
            )
        )
        cfg.commands
        // lib.mapAttrs' (
          name: content:
            lib.nameValuePair ".claude/hooks/${name}" {
              text = content;
            }
        )
        cfg.hooks;
    };
  };
}
