_: {
  # Enable verbose shutdown logging to diagnose hanging user processes
  systemd.settings.Manager = {
    LogLevel = "debug";
    ShowStatus = "yes";
  };

  # Log user session manager verbosely
  systemd.services."user@".serviceConfig = {
    Environment = "SYSTEMD_LOG_LEVEL=debug";
  };
}
