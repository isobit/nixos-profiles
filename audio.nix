{ ... }:
{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Allows real-time scheduling through RTKit, helping reduce latency and audio
  # glitches without running all audio processes as real-time/root.
  security.rtkit.enable = true;

  # Legacy pulseaudio should not be used with pipewire running and providing
  # a pulse compatibility layer.
  services.pulseaudio.enable = false;
}
