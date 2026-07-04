{ config, pkgs, ... }:
{
  programs.obs-studio = {
    enable = true;

    package = (
      pkgs.obs-studio.override {
        # NVIDIA hardware acceleration
        cudaSupport = true;
      }
    );

   # plugins = with pkgs.obs-studio-plugins; [
    # ];
  };
}
