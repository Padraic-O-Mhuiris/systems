{vars, ...}: {
  security.sudo.extraRules = [
    {
      users = [vars.PRIMARY_USER.NAME];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  security.sudo.extraConfig = ''
    # This disables the lecture for all users
    Defaults lecture = never
  '';
}
