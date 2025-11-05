{ modulesPath
, lib
, pkgs
, self
, ...
}:
{
  imports = [
    # (modulesPath + "/installer/scan/not-detected.nix")
    # (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  disko.devices.disk.main.device = "/dev/nvme0n1";
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
    timeoutStyle = "hidden";
  };

  swapDevices = [{
    device = "/nix/swapfile";
    size = 32 * 1024;
  }];

  services.udev = {
    enable = true;
    extraRules = ''
      ENV{LIBINPUT_CALIBRATION_MATRIX}="0 1 0 -1 0 1"
      # Valve USB devices
      SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666"
      # Steam Controller udev write access
      KERNEL=="uinput", SUBSYSTEM=="misc", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
      # Valve HID devices over USB hidraw
      KERNEL=="hidraw*", ATTRS{idVendor}=="28de", MODE="0666"
      # Valve HID devices over bluetooth hidraw
      KERNEL=="hidraw*", KERNELS=="*28DE:*", MODE="0666"
    '';
  };

  environment.persistence."/nix/persist" = {
    enable = true; # NB: Defaults to true, not needed
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      "/var/lib/flatpak"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh_host_ed25519_key"
      "/etc/ssh_host_rsa_key"
    ];
    # users.riky = {
    #   directories = [
    #     # ".local/share/flatpak"
    #     ".var"
    #     "retrodeck"
    #     "Games"
    #   ];
    # };
  };



  networking.hostName = "deck";
  programs.uwsm.enable = true;
  programs.hyprland = {
    withUWSM = true;
    enable = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "uwsm start -S hyprland-uwsm.desktop";
        user = "riky";
      };
    };
  };

  # nix.extraOptions = ''experimental-features = nix-command flakes'';

  services.flatpak.enable = true;
  # xdg.portal = {
  #   enable = true;
  #   extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr ];
  #   config.common.default = "*";
  # };

  services.udisks2.enable = true;

  networking.firewall = {
    enable = true;
    # allowedTCPPorts = [ 25565 ];
    # allowedUDPPorts = [ 24454 ];
  };

  networking.networkmanager.enable = true;

  services.getty.autologinUser = "riky";

  users.users = {
    riky = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPRI8KdIpS8+g0IwxfzmrCBP4m7XWj0KECBz42WkgwsG rikyiso01"
      ];
      extraGroups = [ "wheel" ];
    };
  };

  # programs.tmux.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
    hostKeys = [
      {
        type = "ed25519";
        path = "/nix/persist/etc/ssh/ssh_host_ed25519_key";
      }
      {
        type = "rsa";
        bits = 4096;
        path = "/nix/persist/etc/ssh/ssh_host_rsa_key";
      }
    ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };

  # services.logind.lidSwitch = "ignore";

  security.sudo.wheelNeedsPassword = false;

  programs.fuse.userAllowOther = true;

  powerManagement.powertop.enable = true;

  services.tlp = {
    enable = true;
  };

  # virtualisation.docker.enable = true;

  # system.activationScripts = {
  #   flatpak-setup = {
  #     text = ''
  #       ${pkgs.flatpak}/bin/flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  #       ${pkgs.flatpak}/bin/flatpak install -y --system flathub io.github.flattool.Warehouse tv.kodi.Kodi com.github.tchx84.Flatseal page.codeberg.dnkl.foot net.lutris.Lutris com.usebottles.bottles net.retrodeck.retrodeck org.yuzu_emu.yuzu
  #       ${pkgs.flatpak}/bin/flatpak override --talk-name=org.freedesktop.Flatpak --filesystem=home tv.kodi.Kodi
  #     '';
  #     deps = [ "specialfs" ];
  #   };
  # };


  system.autoUpgrade = {
    enable = true;
    flake = self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "--no-write-lock-file"
      "-L" # print build logs
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
    allowReboot = false;
  };

  system.stateVersion = "24.05";
}
