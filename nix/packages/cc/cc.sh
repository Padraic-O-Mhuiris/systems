#!/usr/bin/env bash
set -euo pipefail

# cc - Run Claude Code in YOLO mode with transparency
# Shows all commands Claude executes in a tmux split pane

# Generate unique session name for this sandbox
project_dir="$(pwd)"

# Try to find git repo root, fallback to current directory
repo_root="$(git rev-parse --show-toplevel 2>/dev/null || echo "$project_dir")"

session_prefix="$(basename "$repo_root")"
session_id="$(printf '%04x%04x' $RANDOM $RANDOM)"
session_name="${session_prefix}-${session_id}"

# Create isolated home directory (protects real home from YOLO mode)
claude_home="/tmp/${session_name}"
at_exit() {
  rm -rf "$claude_home"
}
trap at_exit EXIT
mkdir -p "$claude_home"

# Mount points for Claude config (needs API keys)
claude_config="${HOME}/.claude"
mkdir -p "$claude_config"
claude_json="${HOME}/.claude.json"

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
  rel_path="${real_repo_root#"$real_home"/}"
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

# Mount parent directory tree if working under home
if [[ $share_tree != "$repo_root" ]]; then
  bwrap_args+=(--ro-bind "$share_tree" "$share_tree")
fi

# Git repo root (or current dir) gets full write access (YOLO mode)
bwrap_args+=(--bind "$repo_root" "$repo_root")

# Define log file path
logfile="/tmp/claudebox-commands-${session_name}.log"

# Add logfile to bwrap environment
bwrap_args+=(--setenv CLAUDEBOX_LOG_FILE "$logfile")

# Launch tmux with Claude in left pane, commands in right
bwrap "${bwrap_args[@]}" bash -c "
  # Change to original working directory
  cd '$project_dir'

  # Create the log file
  touch '$logfile'

  exec claude --dangerously-skip-permissions
"
