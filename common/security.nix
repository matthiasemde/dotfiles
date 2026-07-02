{
  config,
  pkgs,
  lib,
  username,
  gpgSigningKey,
  ...
}:

let
  # Cache times in seconds
  h = 60 * 60; # 1 hour
  d = 24 * h; # 1 day
in
{
  # Enable GPG
  programs.gpg = {
    enable = true;
    settings = {
      personal-cipher-preferences = "AES256 AES192 AES";
      personal-digest-preferences = "SHA512 SHA384 SHA256";
      personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
      default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
      cert-digest-algo = "SHA512";
      s2k-digest-algo = "SHA512";
      s2k-cipher-algo = "AES256";
      charset = "utf-8";
      no-comments = true;
      no-emit-version = true;
      no-greeting = true;
      keyid-format = "0xlong";
      list-options = "show-uid-validity";
      verify-options = "show-uid-validity";
      with-fingerprint = true;
      require-cross-certification = true;
      require-secmem = true;
      no-symkey-cache = true;
      armor = true;
      use-agent = true;
      throw-keyids = true;
      default-key = gpgSigningKey;
      trusted-key = gpgSigningKey;
    };
  };

  # Configure GPG agent
  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = false; # let ssh-agent handle ssh auth

      # Cache settings - balance security and convenience
      defaultCacheTtl = 24 * h; # 8 hours for GPG operations
      maxCacheTtl = d; # 1 day maximum
      defaultCacheTtlSsh = 24 * h; # 8 hours for SSH keys
      maxCacheTtlSsh = d; # 1 day maximum

      pinentry.package = pkgs.pinentry-curses;
    };
  };

  # SSH config
  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false; # can be removed once defaults are removed
    settings = {
      "*" = {
        user = username;
        addKeysToAgent = "yes";
        identitiesOnly = true;
        forwardAgent = false;
        # LocalForward = "5010 localhost:5010";
      };
      "mey" = {
        hostname = "91.98.74.56";
        user = "matthias";
        identityFile = "/home/${username}/.ssh/hetzner_v3";
        addKeysToAgent = "yes";
        identitiesOnly = true;
        forwardAgent = false;
        # LocalForward = "5010 localhost:5010";
      };
    };
  };

  # Set up git to use the GPG agent properly
  programs.git.settings = {
    signing.key = gpgSigningKey;
    commit.gpgSign = true;
    tag.gpgSign = true;
    gpg.program = "gpg2";
  };
}
