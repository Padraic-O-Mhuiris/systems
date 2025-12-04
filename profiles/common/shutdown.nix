_: {
  # Enable verbose shutdown logging to diagnose hanging user processes
  systemd.extraConfig = ''
    LogLevel=debug
    ShowStatus=yes
  '';

  # Log user session manager verbosely
  systemd.services."user@".serviceConfig = {
    Environment = "SYSTEMD_LOG_LEVEL=debug";
  };
}
