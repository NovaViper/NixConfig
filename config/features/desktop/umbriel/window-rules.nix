{ ... }:
{
  hm.programs.umbriel.settings.window_rule = [
    # Defaults from Umbriel's examples/config.toml.
    {
      blur = true;
    }
    {
      match.app_id = "^dev.noctalia.Noctalia$";
      default_floating = true;
      default_floating_size_px = {
        width = 1080;
        height = 920;
      };
    }
    {
      match.app_id = "^dev.noctalia.UmbrielSharePicker$";
      default_floating = true;
      default_floating_size_px = {
        width = 800;
        height = 600;
      };
    }
    {
      match.title = "^(Picture-in-Picture|Picture in picture)$";
      default_floating = true;
      default_maximize = false;
      default_position = {
        x = 20;
        y = 20;
        anchor = "bottom_right";
      };
    }
    {
      match.title = "^notificationtoasts_.+_desktop";
      default_focused = false;
      default_pinned = true;
      default_position = {
        x = 0;
        y = 0;
        anchor = "bottom_right";
      };
    }

    # Personal app rules override the defaults above.
    {
      match.app_id = "^(xdg-desktop-portable|qalculate-gtk|qalculate-qt|org\\.pulseaudio\\.pavucontrol)$";
      default_floating = true;
    }
    {
      match = {
        app_id = "^steam$";
        title = "^notificationtoasts_[0-9]+_desktop$";
      };
      default_focused = false;
      default_pinned = true;
      default_position = {
        x = 10;
        y = 10;
        anchor = "bottom_right";
      };
    }
    {
      match.app_id = "^steam_app_[0-9]+$";
      default_workspace = 4;
      default_fullscreen = true;
    }
    # Enable VRR for game content
    {
      match.content_type = "game";
      vrr = "always";
    }
  ];
}
