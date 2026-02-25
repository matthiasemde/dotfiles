{
  pkgs,
  username,
  email,
  homeDirectory,
  gpgSigningKey,
  ...
}:
let
  gpgHelperScript = pkgs.replaceVars ./gpg-helper.sh {
    nixUsername = username;
    nixEmail = email;
    nixHomeDirectory = homeDirectory;
    nixGpgSigningKey = gpgSigningKey;
  };
  gpgHelper = pkgs.writeShellScriptBin "gpg-helper" (builtins.readFile gpgHelperScript);
in
{
  home.packages = [ gpgHelper ];
}
