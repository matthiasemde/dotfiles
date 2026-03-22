{
  lib,
  config,
  ...
}:

{
  options.dotfiles = {
    hostname = lib.mkOption {
      type = lib.types.str;
      default = "generic";
      description = "The hostname of the machine being configured.";
    };

    desktop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this is a desktop (non-headless) machine. Headless by default.";
    };
  };
}
