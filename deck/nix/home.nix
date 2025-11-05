{ config, pkgs, lib, impermanence, ... }:
{
  # TODO please change the username & home directory to your own
  home.username = "riky";
  home.homeDirectory = "/home/riky";

  imports = [ impermanence ];

  home.packages = with pkgs; [
  ];


  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    settings = {
      monitor = [
        "eDP-1,1920x1080@60,auto,1,transform,3"
        ",preferred,auto,1,mirror,eDP-1"
      ];
      exec-once = [
        "${pkgs.flatpak}/bin/flatpak run io.github.flattool.Warehouse"
      ];
      windowrule = [ "maximize,fullscreen:0" ];
      "$mod" = "CAPS";
      bind = [
        ", XF86AudioRaiseVolume, exec, ${pkgs.pamixer}/bin/pamixer --allow-boost -i 10"
        ", XF86AudioLowerVolume, exec, ${pkgs.pamixer}/bin/pamixer --allow-boost -d 10"
        "$mod, XF86AudioRaiseVolume, exec, sudo ${pkgs.brightnessctl}/bin/brightnessctl set 5%+"
        "$mod, XF86AudioLowerVolume, exec, sudo ${pkgs.brightnessctl}/bin/brightnessctl set 5%-"
      ];
      animations = { enabled = "no"; };
      general = { border_size = 0; gaps_in = 0; gaps_out = 0; };
      input = { kb_options = "caps:swapescape"; };
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr ];
    config.common.default = "*";
  };

  # home.activation = {
  #   flatpak-setup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #     ${pkgs.flatpak}/bin/flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  #     ${pkgs.flatpak}/bin/flatpak install -y --user flathub io.github.flattool.Warehouse tv.kodi.Kodi com.github.tchx84.Flatseal page.codeberg.dnkl.foot net.lutris.Lutris com.usebottles.bottles net.retrodeck.retrodeck org.yuzu_emu.yuzu || true
  #     ${pkgs.flatpak}/bin/flatpak override --user --talk-name=org.freedesktop.Flatpak --filesystem=home tv.kodi.Kodi
  #     ${pkgs.flatpak}/bin/flatpak remote-add --user --if-not-exists gnome-nightly https://nightly.gnome.org/gnome-nightly.flatpakrepo
  #     ${pkgs.flatpak}/bin/flatpak install -y --user gnome-nightly org.gnome.Nautilus.Devel || true
  #   '';
  # };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  home.persistence = {
    "/nix/persist/home/${config.home.username}" = {
      directories = [
        ".local/share/flatpak"
        ".var"
        "retrodeck"
        "Games"
      ];
      allowOther = true;
    };
  };


  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";
}
