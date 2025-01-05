{ inputs, ... }:

{
  imports = [ inputs.pre-commit-hooks.flakeModule ];

  perSystem.pre-commit = {
    settings.excludes = [ "flake.lock" ];
    settings.hooks = {
      statix.enable = true;
      prettier = {
        enable = true;
        excludes = [ ".md" ];
      };
    };
  };
}
