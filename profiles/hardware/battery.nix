{pkgs, ...}: {
  # TLP - Advanced power management for Linux
  # Note: TLP conflicts with auto-cpufreq, only enable one
  services.tlp = {
    enable = true;
    settings = {
      # CPU scaling governor
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # CPU energy/performance policy (HWP.EPP)
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      # CPU boost
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      # Platform profile (modern laptops)
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      # Battery charge thresholds (Dell-specific ranges)
      # Helps preserve battery health by not charging to 100%
      # Dell supports: START 50-95%, STOP 55-100%
      START_CHARGE_THRESH_BAT0 = 50;
      STOP_CHARGE_THRESH_BAT0 = 80;

      # USB autosuspend
      USB_AUTOSUSPEND = 1;

      # Runtime power management
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";

      # WiFi power saving
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";
    };
  };

  # Power monitoring and management
  services.upower = {
    enable = true;
    percentageLow = 15;
    percentageCritical = 5;
    percentageAction = 3;
    criticalPowerAction = "Hibernate";
  };

  # Thermal management (Intel CPUs)
  services.thermald.enable = true;

  # Useful power management tools
  environment.systemPackages = with pkgs; [
    powertop # Power consumption analysis
    acpi # Battery/AC status
    tlp # TLP CLI tools
  ];

  # Enable laptop mode for better disk power management
  powerManagement.enable = true;

  # Alternative: auto-cpufreq (uncomment to use instead of TLP)
  # services.auto-cpufreq.enable = true;
  # services.auto-cpufreq.settings = {
  #   charger = {
  #     governor = "performance";
  #     turbo = "auto";
  #   };
  #   battery = {
  #     governor = "powersave";
  #     turbo = "auto";
  #   };
  # };
}
