# Server-specific settings for headless/clamshell Mac
# Keeps the machine awake with lid closed for SSH access
{ config, pkgs, ... }:

{
  # Override power management for server use
  system.activationScripts.power.text = ''
    # Server mode: never sleep, even with lid closed
    pmset -a disablesleep 1
    pmset -a sleep 0
    pmset -a disksleep 0
    pmset -a displaysleep 0
    pmset -a hibernatemode 0
    pmset -a powernap 0

    # Disable standby (deep sleep that kicks in after prolonged idle)
    pmset -a standby 0
    pmset -a autopoweroff 0

    # Prevent sleep on lid close (requires power adapter)
    pmset -a lidwake 1

    # Wake on network access (for Wake-on-LAN)
    pmset -a womp 1

    # Restart automatically after power failure
    pmset -a autorestart 1
  '';
}
