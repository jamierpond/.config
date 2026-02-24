# OpenClaw — AI gateway service
# Add this module to machines that should run OpenClaw on boot.
{ config, pkgs, ... }:

{
  launchd.daemons.openclaw = {
    serviceConfig = {
      Label = "com.openclaw.gateway";
      ProgramArguments = [
        "${pkgs.nodejs_22}/bin/node"
        "/Users/jamiepond/projects/openclaw/openclaw.mjs"
      ];
      WorkingDirectory = "/Users/jamiepond/projects/openclaw";
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/tmp/openclaw.log";
      StandardErrorPath = "/tmp/openclaw.log";
      EnvironmentVariables = {
        PATH = "${pkgs.nodejs_22}/bin:/usr/bin:/bin";
        HOME = "/Users/jamiepond";
      };
    };
  };
}
