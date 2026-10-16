{ config, ... }:
{
  dotfiles = {
    profiles.matthias = {
      homeDirectory = "/home/matthias";
      email = "matthias@emdemail.de";
      gpgSigningKey = "AD15BE5E42AD3039";
      modules = [ config.flake.modules.homeManager.personal ];
    };

    hosts = {
      vogel.profile = "matthias";
      hindemith.profile = "matthias";
    };
  };
}
