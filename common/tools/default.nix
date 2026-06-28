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

  txt2htmlPreview = pkgs.writeShellScriptBin "txt2htmlPreview" (
    builtins.readFile ./txt2htmlPreview.sh
  );
in
{
  home.packages = [
    gpgHelper
    txt2htmlPreview
  ];
}
