{ config, pkgs, ... }:

let
  unstable = import
    (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/nixos-unstable)
    { config = config.nixpkgs.config; };

  neovimCustom = unstable.neovim;
  # neovimCustom = let pkgs = unstable; in (pkgs.neovim.override {
  #     configure = {
  #       customRC = ''
  #         source ~/.vimrc
  #       '';
  #       packages.myPlugins = with pkgs.vimPlugins; {
  #         start = [
  #           (nvim-treesitter.withPlugins ( plugins: pkgs.tree-sitter.allGrammars))
  #         ];
  #       };
  #     };
  #   });
in
{
  environment.systemPackages = with pkgs; [
    neovimCustom

    neovide # nice client with fancy animations

    # language servers
    efm-langserver       # wraps other linting tools
    gopls                # golang
    rnix-lsp             # nix
    sqls                 # SQL
    terraform-ls         # terraform
    yaml-language-server # YAML
    # python-language-server # Python
    python3Packages.python-lsp-server # Python

    # general purpose linting tools (used by efm-langserver)
    checkmake               # Makefile
    hadolint                # Dockerfile
    jq                      # JSON
    rubyPackages.solargraph # ruby
    yamllint                # YAML
    deno                    # Javascript/TypeScript
  ];
}
