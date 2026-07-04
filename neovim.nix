{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    configure = {
      customRC = ''
        luafile ~/.config/nvim/init.lua
      '';
      packages.treesitter.start = [
        pkgs.vimPlugins.nvim-treesitter.withAllGrammars
      ];
    };
  };
  environment.systemPackages = with pkgs; [
    # language servers
    cuelsp                            # CUE
    efm-langserver                    # wraps other linting tools
    gopls                             # golang
    nixd                              # nix
    python3Packages.python-lsp-server # Python
    sqls                              # SQL
    terraform-ls                      # terraform
    yaml-language-server              # YAML

    # general purpose linting tools (used by efm-langserver)
    checkmake               # Makefile
    hadolint                # Dockerfile
    jq                      # JSON
    # rubyPackages.solargraph # ruby
    # yamllint                # YAML
    # deno                    # Javascript/TypeScript
  ];
}
