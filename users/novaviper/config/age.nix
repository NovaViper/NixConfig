{
  config,
  outputs,
  name,
  ...
}: {
  userIdentityPaths = outputs.lib.mkSecretIdentities ["age-yubikey-identity-a38cb00a-usba.txt"];

  age.secrets."borg_token" = outputs.lib.mkSecretFile {
    user = name;
    source = "borg.age";
    destination = "${config.xdg.configHome}/borg/keys/srv_dev_disk_by_uuid_5aaed6a3_d2c7_4623_b121_5ebb8d37d930_Backups";
  };
}
