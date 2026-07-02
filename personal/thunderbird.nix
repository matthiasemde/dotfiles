{
  config,
  lib,
  email,
  ...
}:

lib.mkIf config.dotfiles.desktop {
  programs.thunderbird = {
    enable = true;
    profiles.matthias = {
      isDefault = true;
    };
  };

  accounts.email.accounts."matthias@emdemail.de" = {
    primary = true;
    address = "matthias@emdemail.de";
    realName = "Matthias Emde";
    userName = "matthias@emde-it-loesungen.de"; # used for authentication

    imap = {
      host = "sslmailpool.ispgateway.de";
      port = 993;
      authentication = "login";
      tls.enable = true;
    };

    smtp = {
      host = "smtprelaypool.ispgateway.de";
      port = 465;
      authentication = "login";
      tls = {
        enable = true;
        useStartTls = false; # port 465 = implicit TLS, not STARTTLS
      };
    };

    thunderbird = {
      enable = true;
      profiles = [ "matthias" ];
    };
  };
}
