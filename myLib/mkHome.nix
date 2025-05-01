flake@{
  inputs,
  self,
  lib,
  myLib,
  ...
}:
let
  # Helper functions we don't plan on exporting past this file
  internals = {
    atSignSplit = string: lib.splitString "@" string;

    # Grab everything before the @ in "username@hostname", from llakala
    guessUsername =
      userhost:
      if lib.length (internals.atSignSplit userhost) == 2 then
        lib.elemAt (internals.atSignSplit userhost) 0 # First value in list
      else
        throw "Invalid userhost format: ${userhost}. Expected format: username@hostname";

    # Grab everything after the @ in "username@hostname", from llakala
    guessHostname =
      userhost:
      if lib.length (internals.atSignSplit userhost) == 2 then
        lib.elemAt (internals.atSignSplit userhost) 1 # Second value in list
      else
        throw "Invalid userhost format: ${userhost}. Expected format: username@hostname";
  };

  # Helper function for creating the system config for Home-Manager
  mkHome =
    userhost:
    {
      nixosConfigurations,
      username ? internals.guessUsername userhost,
      hostname ? internals.guessHostname userhost,
    #stateVersion ? myLib.conds.defaultStateVersion,
    }:
    /*
        lib.homeManagerConfiguration {
        extraSpecialArgs = flake // {inherit username hostname stateVersion;};
      };
    */
    nixosConfigurations.${hostname}.config.home-manager.users.${username}.home; # allows me to independently switch my home environment without rebuilding my entire system
in
mkHome
