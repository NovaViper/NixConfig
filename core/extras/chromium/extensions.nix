{ lib, pkgs, ... }:
let
  extensions = [
    { id = "gebbhagfogifgggkldgodflihgfeippi"; } # Return Dislikes
    { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; } # Sponsor Block
    { id = "kdbmhfkmnlmbkgbabkdealhhbfhlmmon"; } # SteamDB
    { id = "oboonakemofpalcgghocfoadofidjkkk"; } # KeepassXC
    { id = "ponfpcnoihfmfllpaingbgckeeldkhle"; } # Enhancer for YouTube
    { id = "fonfeflegdnbhkfefemcgbdokiinjilg"; } # Chat Replay
    { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # Dark Reader
    { id = "hmgpakheknboplhmlicfkkgjipfabmhp"; } # Pay
    { id = "cimiefiiaegbelhefglklhhakcgmhkai"; } # Plasma Browser Integration
    { id = "fkagelmloambgokoeokbpihmgpkbgbfm"; } # Indie Wiki Buddy
    { id = "clngdbkpkpeebahjckkjfobafhncgmne"; } # Stylus
    { id = "jinjaccalgkegednnccohejagnlnfdag"; } # Violetmonkey
  ];
in
{

  hmUser = lib.singleton (
    hm:
    let
      hm-config = hm.config;
    in
    {
      programs.brave = { inherit extensions; };
      programs.vivaldi = { inherit extensions; };
    }
  );
}
