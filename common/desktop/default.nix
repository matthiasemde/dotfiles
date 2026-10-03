{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./vscode
    ./window-manager
    ./firefox
  ];

  config = lib.mkIf config.dotfiles.desktop.enable {

    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      feishin
      signal-desktop
      keymapp
      vlc
    ];

    programs.element-desktop = {
      enable = true;
      settings = {
        default_server_config = {
          "m.homeserver" = {
            base_url = "https://matrix.emdecloud.de";
            server_name = "emdecloud.de";
          };
          "m.identity_server" = {
            base_url = "https://vector.im";
          };
        };
        disable_custom_urls = false;
        disable_guests = false;
        disable_login_language_selector = false;
        disable_3pid_login = false;
        force_verification = false;
        brand = "Element";
        integrations_ui_url = "https://scalar.vector.im/";
        integrations_rest_url = "https://scalar.vector.im/api";
      };
    };

    dotfiles.wine.programs = {
      mp3tag = {
        url = "https://download.mp3tag.de/mp3tag-v3.35.1-x64-setup.exe";
        sha256 = "5be51f75691fb3556bb069bf5800ba5872cd3e38fb0bbec35715e5cde5f2d9ad";
        installedExe = "Program Files/Mp3tag/Mp3tag.exe";
      };
      irfanview = {
        url = "https://domainunion.de/irfanview/iview475g_x64_setup.exe";
        sha256 = "6b7e36c089194347be1bea5fea08dc97316f2181e40427e7e2867ad7ba3906a0";
        installedExe = "Program Files/IrfanView/i_view64.exe";
      };
    };
  };
}
