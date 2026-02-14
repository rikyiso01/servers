{ config, pkgs, lib, ... }:
{
  home.username = "riky";
  home.homeDirectory = "/home/riky";

  home.packages = with pkgs; [
    nerd-fonts.fira-mono
  ];


  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    settings = {
      monitor = [
        "eDP-1,800x1280@60,0x0,1,transform,3"
        ",preferred,auto,1,mirror,eDP-1"
      ];
      exec-once = [
        "${pkgs.flatpak}/bin/flatpak run io.github.flattool.Warehouse"
      ];
      windowrule = [ "match:title .*, maximize on" ];
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

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        output = "eDP-1";
        layer = "top";
        position = "top";
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "custom/clock" ];
        modules-right = [ "pulseaudio" "cpu" "memory" "backlight" "battery" "network" "power-profiles-daemon" "bluetooth" "tray" ];
        "custom/clock" = {
          format = " {}";
          exec = "date +'%a, %d %b, %R'";
          interval = 1;
        };
        pulseaudio = {
          reverse-scrolling = 1;
          format = "{icon} {volume}% {format_source}";
          format-bluetooth = " {volume}% {format_source}";
          format-bluetooth-muted = " {format_source}";
          format-muted = "󰸈 {format_source}";
          format-source = " {volume}%";
          format-source-muted = "";
          format-icons = {
            default = [ "" "" "" ];
          };
          on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
        };
        cpu = {
          interval = 2;
          format = " {usage}%";
        };
        memory = {
          interval = 2;
          format = " {percentage}%  {swapPercentage}%";
        };
        network = {
          format-wifi = "󰤨 {essid}";
          format-ethernet = "󰈀";
          format-disconnected = "󰤭";
          on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
        };
        bluetooth = {
          format = "󰂯";
          format-disabled = "󰂲";
          format-connected = "󰂱";
        };
        power-profiles-daemon = {
          "format-icons" = {
            "balanced" = "";
            "performance" = "󰈸";
            "power-saver" = "󰌪";
          };
        };
        backlight = {
          device = "intel_backlight";
          format = "{icon} {percent}%";
          format-icons = [ "" ];
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon}? {capacity}%";
          format-plugged = " {capacity}%";
          format-charging = " {capacity}%";
          format-discharging = "{icon} {capacity}%";
          format-icons = [ "" "" "" "" "" ];
        };

        tray = {
          icon-size = 16;
          spacing = 0;
        };
      };
    };
    style = ''
      @define-color base   #1e1e2e;
      @define-color mantle #181825;
      @define-color crust  #11111b;

      @define-color text     #cdd6f4;
      @define-color subtext0 #a6adc8;
      @define-color subtext1 #bac2de;

      @define-color surface0 #313244;
      @define-color surface1 #45475a;
      @define-color surface2 #585b70;

      @define-color overlay0 #6c7086;
      @define-color overlay1 #7f849c;
      @define-color overlay2 #9399b2;

      @define-color blue      #89b4fa;
      @define-color lavender  #b4befe;
      @define-color sapphire  #74c7ec;
      @define-color sky       #89dceb;
      @define-color teal      #94e2d5;
      @define-color green     #a6e3a1;
      @define-color yellow    #f9e2af;
      @define-color peach     #fab387;
      @define-color maroon    #eba0ac;
      @define-color red       #f38ba8;
      @define-color mauve     #cba6f7;
      @define-color pink      #f5c2e7;
      @define-color flamingo  #f2cdcd;
      @define-color rosewater #f5e0dc;

      *{
          font-family: 'FiraMono Nerd Font Mono';
          /*font-family: 'FiraCode Nerd Font Mono';*/
          font-size: 1em;
          background: transparent;
          /* color: #ffffff; */
      }

      .module{
          background-color: @surface0;
          padding: 0 1rem;
          color: @text;
      }

      #workspaces{
          padding: 0;
          margin-left: 1rem;
          border-radius: 1rem;
      }

      #workspaces button{
          color: @lavender;
          border-radius: inherit;
          border: none;
      }

      #workspaces button.active{
          color: @sky;
      }

      #workspaces button:hover{
          color: @sapphire;
      }

      #pulseaudio{
        color: @maroon;
        border-radius: 1rem 0 0 1rem;
        margin-left: 1rem;
      }

      #battery{
          color: @green;
          border-radius: 0 1rem 1rem 0;
          margin-right: 1rem;
      }

      #battery.plugged,
      #battery.charging{
          background-color: #26A65B;
          color: @text;
      }

      #battery.warning:not(.charging) {
          background-color: #FFBE61;
          color: @text;
      }

      #battery.critical:not(.charging) {
          background-color: #F53C3C;
          color: @text;
      }

      #custom-clock {
          color: @mauve;
      }

      #cpu,
      #memory
      {
          color: @peach;
      }

      #backlight{
          color: @yellow;
      }

      #tray,
      #custom-clock
      {
          border-radius: 1rem;
      }

      #tray{
          margin-right: 1rem;
      }

      #bluetooth{
          border-radius: 0 1rem 1rem 0;
          margin-right: 1rem;
      }

      #network{
          border-radius: 1rem 0 0 1rem;
      }
    '';
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
    "/nix/persist" = {
      directories = [
        ".local/share/flatpak"
        ".var"
        "retrodeck"
        "Games"
      ];
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
