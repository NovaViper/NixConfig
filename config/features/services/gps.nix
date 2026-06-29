_: {
  # Enable automatic timezone detection
  services.automatic-timezoned.enable = true;

  # enable location service
  location.provider = "geoclue2";

  # provide location
  services.geoclue2 = {
    enable = true;
    enableDemoAgent = true;
    geoProviderUrl = "https://api.beacondb.net/v1/geolocate";
    submitData = true;
    submissionUrl = "https://api.beacondb.net/v2/geosubmit";
    submissionNick = "geoclue";
  };
}
