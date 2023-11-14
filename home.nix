{ config, pkgs, ... }:

{
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      font-hinting = "none";
      font-antialiasing = "greyscale";
    };
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
    };
  };

  home = {
    homeDirectory = "/home/tlv";
    sessionVariables = {
      XCURSOR_THEME = "Adwaita";
      XCURSOR_SIZE = 16;
      ZSHZ_CMD = "j";
    };
    stateVersion = "23.05";
    username = "tlv";
  };

  programs.firefox = {
    enable = true;
    profiles.default = {
      search = {
        default = "Brave";
        engines = {
          "Arch Wiki" = {
            urls = [{
              template = "https://wiki.archlinux.org/index.php";
              params = [
                { name = "search"; value = "{searchTerms}"; }
              ];
            }];
            definedAliases = [ "aw" ];
          };

          Brave = {
            urls = [{
              template = "https://search.brave.com/search";
              params = [
                { name = "q"; value = "{searchTerms}"; }
              ];
            }];
            definedAliases = [ "b" ];
          };

          "NixOS Options" = {
            urls = [{
              template = "https://search.nixos.org/options";
              params = [
                { name = "channel"; value = "unstable"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "no" ];
          };

          "NixOS Packages" = {
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                { name = "channel"; value = "unstable"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "np" ];
          };

          Wikipedia = {
            urls = [{
              template = "https://en.m.wikipedia.org/w/index.php";
              params = [
                { name = "search"; value = "{searchTerms}"; }
              ];
            }];
            definedAliases = [ "w" ];
          };
        };
      };

      settings = {
	"dom.security.https_only_mode" = true;
	"extensions.pocket.enabled" = false;
	"media.ffmpeg.vaapi.enabled" = true;
	"ui.key.menuAccessKeyFocuses" = false;
      };
    };
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "monospace:size=14";
        #initial-window-mode = "fullscreen";
      };
      cursor = {
        style = "beam";
        blink = "yes";
        beam-thickness = 1;
      };
    };
  };

  programs.git = {
    enable = true;
    userName = "Tom Vincent";
    userEmail = "git@tlvince.com";
    signing = {
      key = "AB184CDBE6AEACDE";
      signByDefault = true;
    };
  };

  programs.gpg = {
    enable = true;
    settings = {
      default-key = "E6AEACDE";
      default-recipient-self = true;
      keyserver = "hkp://keys.gnupg.net";
      keyserver-options = "auto-key-retrieve";
      use-agent = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    enableScDaemon = false;
    defaultCacheTtl = 28800; # 8 hours
    defaultCacheTtlSsh = 28800; # 8 hours
    maxCacheTtl = 57600; # 16 hours
    maxCacheTtlSsh = 57600; # 16 hours
    pinentryFlavor = "gnome3";
  };

  programs.home-manager.enable = true;

  programs.mpv = {
    enable = true;
    config = {
      hwdec = "auto";
      ytdl-format = "(bestvideo[vcodec^=av01][height<=?2160]/bestvideo[height<=?2160])+bestaudio/best";
    };
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    initExtra = ''
    autoload -U promptinit; promptinit
    prompt pure

    source ${pkgs.zsh-z}/share/zsh-z/zsh-z.plugin.zsh
    '';
  };
}
