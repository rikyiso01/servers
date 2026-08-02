{ config, pkgs, lib, ... }:
{
  home.username = "riky";
  home.homeDirectory = "/home/riky";

  home.packages = with pkgs; [
    nerd-fonts.fira-mono
    appimage-run
    file
    pamixer
    brightnessctl
    wvkbd
    noctalia
  ];


  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    configType = "lua";
    extraLuaFiles."config".content = ./hyprland.lua;
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

  programs.neovim = {
    enable = true;
    withRuby = false;
    withPython3 = false;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr ];
    config.common.default = "*";
  };

  services.flatpak = {
    enable = true;
    packages = builtins.map (x: { appId = x; origin = "flathub"; }) [
      "com.github.tchx84.Flatseal"
      "com.usebottles.bottles"
      "io.github.flattool.Warehouse"
      "it.mijorus.gearlever"
      "net.lutris.Lutris"
      "net.retrodeck.retrodeck"
      "org.yuzu_emu.yuzu"
      "page.codeberg.dnkl.foot"
      "tv.kodi.Kodi"
    ]
    ++
    [{ appId = "org.gnome.Nautilus.Devel"; origin = "gnome-nightly"; }];
    remotes = [{ name = "flathub"; location = "https://dl.flathub.org/repo/flathub.flatpakrepo"; }
      { name = "gnome-nightly"; location = "https://nightly.gnome.org/gnome-nightly.flatpakrepo"; }];
    overrides = {
      "tv.kodi.Kodi" = { Context.filesystems = [ "home" ]; "Session Bus Policy" = { "org.freedesktop.Flatpak" = "talk"; "org.freedesktop.NetworkManager" = "talk"; }; };
    };

    uninstallUnmanaged = true;

  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  home.persistence = {
    "/nix/persist" = {
      directories = [
        ".local/share/flatpak"
        ".local/share/FasterThanLight"
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
