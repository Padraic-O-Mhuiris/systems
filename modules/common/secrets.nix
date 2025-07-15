{
  inputs,
  vars,
  ...
}: {
  imports = [
    inputs.secrets.nixosModules.default
  ];

  home-manager.users.${vars.PRIMARY_USER.NAME} = _: {
    imports = [
      inputs.secrets.homeModules.default
    ];
  };
}
