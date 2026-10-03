{
  config,
  lib,
  email,
  ...
}:

let
  c = config.lib.stylix.colors.withHashtag;
in
lib.mkIf config.dotfiles.desktop.enable {
  programs.thunderbird = {
    enable = true;
    profiles.matthias = {
      isDefault = true;

      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };

      userChrome = ''
        :root {
          --bg:        ${c.base00};
          --bg-raised: ${c.base01};
          --surface:   ${c.base02};
          --muted:     ${c.base03};
          --fg:        ${c.base05};
          --primary:   ${c.base0D};
          --accent:    ${c.base0C};
          --error:     ${c.base08};
        }

        /* Main window */
        #messengerWindow,
        #mail-menubar,
        .toolbar-primary,
        #tabs-toolbar {
          background-color: var(--bg) !important;
          color: var(--fg) !important;
        }

        /* Sidebar (folder tree) */
        #folderTree,
        #folderTree treechildren,
        .sidebar-header {
          background-color: var(--bg-raised) !important;
          color: var(--fg) !important;
        }

        /* Selected folder */
        #folderTree treechildren::-moz-tree-row(selected),
        #folderTree treechildren::-moz-tree-row(selected, focus) {
          background-color: var(--primary) !important;
          color: var(--bg) !important;
        }

        /* Hovered folder */
        #folderTree treechildren::-moz-tree-row(hover) {
          background-color: var(--surface) !important;
        }

        /* Message list */
        #threadTree,
        #threadTree treechildren {
          background-color: var(--bg) !important;
          color: var(--fg) !important;
        }

        #threadTree treechildren::-moz-tree-row(selected),
        #threadTree treechildren::-moz-tree-row(selected, focus) {
          background-color: var(--surface) !important;
          color: var(--fg) !important;
        }

        /* Tabs */
        .tab-background[selected="true"] {
          background-color: var(--bg-raised) !important;
        }

        .tab-background {
          background-color: var(--bg) !important;
        }

        /* Toolbar buttons */
        toolbarbutton {
          color: var(--fg) !important;
        }

        toolbarbutton:hover {
          background-color: var(--surface) !important;
          border-radius: 4px;
        }
      '';
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
