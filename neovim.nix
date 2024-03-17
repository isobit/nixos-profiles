{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    neovim

    # language servers
    efm-langserver                    # wraps other linting tools
    gopls                             # golang
    nil                               # nix
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
