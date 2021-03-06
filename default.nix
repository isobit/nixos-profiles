{ config, lib, pkgs, ... }:

{
  boot.loader = {
    systemd-boot.enable = lib.mkDefault true;
    efi.canTouchEfiVariables = lib.mkDefault true;
  };

  console.keyMap = lib.mkDefault "us";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  time.timeZone = lib.mkDefault "UTC";

  programs = {
    less.enable = true;
    zsh = {
      enable = true;
      promptInit = ""; # Disable default promptinit to fix leftover right prompt
    };
  };

  environment.systemPackages = with pkgs; [
    bash
    bat
    bc
    bind # includes dig
    curl
    direnv
    fd
    file
    fzf
    git-lfs
    # gitAndTools.delta
    (import (fetchTarball "channel:nixos-unstable") {}).gitAndTools.delta
    gitAndTools.gitFull
    gnumake
    gnupg
    gnutar
    htop
    jq
    moreutils
    neovim
    pstree
    python3Full
    ripgrep
    screen
    tree
    units
    unzip
    wget
    zip
  ];

  users.users = {
    josh = {
      isNormalUser = true;
      createHome = true;
      extraGroups = [ "wheel" "networkmanager" ];
      initialHashedPassword = "$6$4EONW0LEpTW$KOPBWFYOHJXX5WPFCioSLZe4FoXqxa33GPtO08deL84Y2IxHvzrvr3KqRQL9Tx7xw95RykIVP918uywPJZuZI/";
      shell = pkgs.zsh;
    };
  };

  # Need to use mkAfter to override auto-generated %wheel rules
  security.sudo.extraRules = lib.mkAfter [
    {
      users = [ "josh" ];
      commands = [ { command = "ALL"; options = [ "NOPASSWD" "SETENV" ]; } ]; 
    }
  ];
}
