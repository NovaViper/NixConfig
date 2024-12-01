{
  config,
  pkgs,
  ...
}: let
  hm-config = config.hm;
in {
  home.shellAliases.reload-plasma-theming = "~/.local/share/plasma-manager/run_all.sh";

  hm.programs.plasma = {
    enable = true;
    session.general.askForConfirmationOnLogout = true;
    session.sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";
    kwin = {
      titlebarButtons = {
        left = ["close" "maximize" "minimize"];
        right = ["keep-above-windows" "on-all-desktops"];
      };
      borderlessMaximizedWindows = true;
    };
    hotkeys.commands."restart-plasmashell" = {
      name = "Restart Plasmashell";
      key = "Meta+Alt+R";
      command = "${pkgs.restart-plasma}/bin/restart-plasma";
    };
    configFile = {
      kdeglobals = let
        # Auto switch terminal application desktop file
        terminal =
          if builtins.hasAttr "TERMINAL" hm-config.home.sessionVariables
          then "${hm-config.home.sessionVariables.TERMINAL}"
          else "org.kde.konsole";
      in {
        General.TerminalApplication = "${terminal}.destop";
        General.TerminalService = "${terminal}.desktop";
      };
      kservicemenurc.Show = {
        "compressfileitemaction" = true;
        "extractfileitemaction" = true;
        "forgetfileitemaction" = true;
        "installFont" = true;
        "kactivitymanagerd_fileitem_linking_plugin" = true;
        "kdeconnectfileitemaction" = true;
        "kio-admin" = true;
        "makefileactions" = true;
        "mountisoaction" = true;
        "plasmavaultfileitemaction" = true;
        "runInKonsole" = true;
        "slideshowfileitemaction" = true;
        "tagsfileitemaction" = true;
        "wallpaperfileitemaction" = true;
      };
      dolphinrc = {
        ContentDisplay.UsePermissionsFormat = "CombinedFormat";
        VersionControl.enabledPlugins = "Git";
        General = {
          "AutoExpandFolders" = true;
          "FilterBar" = true;
          "ShowFullPathInTitlebar" = true;
          "ShowToolTips" = true;
          "SortingChoice" = "CaseInsensitiveSorting";
          "UseTabForSwitchingSplitView" = true;
        };
        PreviewSettings.Plugins = "appimagethumbnail,audiothumbnail,blenderthumbnail,comicbookthumbnail,cursorthumbnail,djvuthumbnail,ebookthumbnail,exrthumbnail,directorythumbnail,fontthumbnail,imagethumbnail,jpegthumbnail,kraorathumbnail,windowsexethumbnail,windowsimagethumbnail,mobithumbnail,opendocumentthumbnail,gsthumbnail,rawthumbnail,svgthumbnail,ffmpegthumbs";
      };
    };
  };
}
