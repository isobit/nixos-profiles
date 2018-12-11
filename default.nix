{ config, lib, pkgs, ... }:

{
  boot.loader = {
    systemd-boot.enable = lib.mkDefault true;
    efi.canTouchEfiVariables = lib.mkDefault true;
  };

  i18n = {
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "America/Chicago";

  programs = {
    less.enable = true;
    # thefuck.enable = true;
    zsh = {
      enable = true;
      promptInit = ""; # Disable default promptinit to fix leftover right prompt
    };
  };

  environment.systemPackages = with pkgs; [
    bash
    curl
    gitAndTools.gitFull
    gnutar
    htop
    jq
    pstree
    python3Full
    ruby
    screen
    subversion
    unzip
    vim 
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
