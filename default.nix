{ config, lib, pkgs, ... }:

{
  imports = [
    ./neovim.nix
  ];

  boot.loader = {
    systemd-boot.enable = lib.mkDefault true;
    efi.canTouchEfiVariables = lib.mkDefault true;
  };

  boot.kernel.sysctl = {
    # The default for this is 15, which lets the kernel retransmit unacked TCP
    # packets for up to ~15 minutes (using an exponential backoff) before
    # closing the connection. Reducing this to 5 gives a much lower timeout of
    # ~12.6 seconds. Note thatRFC 1122 recommends at least 100 seconds for the
    # timeout, which corresponds to a value of at least 8.
    # See https://pracucci.com/linux-tcp-rto-min-max-and-tcp-retries2.html for
    # more info.
    "net.ipv4.tcp_retries2" = 5;
  };

  console.keyMap = lib.mkDefault "us";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  time.timeZone = lib.mkDefault "UTC";

  programs = {
    direnv.enable = true;
    less.enable = true;
    nix-ld.enable = true;
    zsh = {
      enable = true;
      promptInit = ""; # Disable default promptinit to fix leftover right prompt
    };
  };

  # Enable nix command and flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    bash
    bat
    bc
    bind # includes dig
    curl
    direnv
    entr
    fd
    file
    fq
    fzf
    gnumake
    gnupg
    gnutar
    gron
    htop
    jq
    moreutils
    nixos-option
    openssl
    pstree
    python3Full
    ripgrep
    rq
    screen
    sd
    tree
    units
    unzip
    wget
    zip

    # TODO how to deal with this vs separate import
    #neovim

    # git
    gitFull
    git-lfs
    git-absorb
    delta
    lazygit

    # networking tools
    conntrack-tools
    nmap
    nftables

    # heavier dev tools
    gh # github cli
    pgcli
    rq
    shellcheck
    steampipe

    cue
    jsonnet
  ];

  users.users = {
    josh = {
      isNormalUser = true;
      createHome = true;
      shell = pkgs.zsh;
      extraGroups = [ "wheel" "networkmanager" "dialout" ];
      initialHashedPassword = "$6$4EONW0LEpTW$KOPBWFYOHJXX5WPFCioSLZe4FoXqxa33GPtO08deL84Y2IxHvzrvr3KqRQL9Tx7xw95RykIVP918uywPJZuZI/";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKn5LaTEdKNI+Vtec3i1E+WHBJFwS/4yGYW6hqzF/7fX josh@isobit.io 2023-03-27"
      ];
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
