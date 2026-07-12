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
      nerd-fonts.iosevka
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
  };
}
