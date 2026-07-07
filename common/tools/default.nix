{
  lib,
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

  groovy-lint = pkgs.buildNpmPackage (finalAttrs: {
    pname = "npm-groovy-lint";
    version = "17.0.5";

    src = pkgs.fetchFromGitHub {
      owner = "nvuillam";
      repo = "npm-groovy-lint";
      tag = "v${finalAttrs.version}";
      hash = "sha256-Cq4SPOqR2mb2Foc1jlrA6B7qJBcmgLfcC84iTc4+tcw=";
    };

    npmDepsHash = "sha256-XGXiuqA0JmuFVretXDjWejV9HJAK6eWR9/LR3rUI99s=";

    meta = with lib; {
      description = "Lint, format and auto-fix Groovy / Jenkinsfile";
      homepage = "https://github.com/nvuillam/npm-groovy-lint";
      license = licenses.mit; # check upstream
      platforms = platforms.all;
    };
  });
in
{
  home.packages = [
    gpgHelper
    txt2htmlPreview
    groovy-lint
  ];
}
