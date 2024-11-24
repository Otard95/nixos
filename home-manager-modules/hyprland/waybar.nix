{ config, lib, pkgs, theme, ... }:
let
  cfg = config.modules.hyprland.waybar;
  enable = cfg.enable;
in {

  options.modules.hyprland.waybar.enable = lib.mkEnableOption "waybar configuration";

  config = lib.mkIf enable {
    home.packages = with pkgs; [
      waybar
    ];

    programs.waybar = {
      enable = true;

      settings = [
        # Top bar config
        {
          "name" = "top_bar";
          "layer" = "top"; # Waybar at top layer
          "position" = "top"; # Waybar position (top|bottom|left|right)
          "height" = 36; # Waybar height (to be removed for auto height)
          "spacing" = 4; # Gaps between modules (4px)
          "margin-top" = 10;
          "margin-left" = 15;
          "margin-right" = 15;
          "modules-left" = ["hyprland/workspaces" "hyprland/submap" "hyprland/window"];
          "modules-center" = ["clock#time" "custom/separator_dot" "clock#week" "custom/separator_dot" "clock#calendar"];
          "modules-right" = [ "network" "pulseaudio" "group/keyoard" "group/hardware" "group/misc" "custom/logout_menu" ];

          # Modules Config
          "hyprland/workspaces" = {
            "on-click" = "activate";
            "format" = "{icon}";
            "format-icons" = {
              # "1" = "󰲠";
              # "2" = "󰲢";
              # "3" = "󰲤";
              # "4" = "󰲦";
              # "5" = "󰲨";
              # "6" = "󰲪";
              # "7" = "󰲬";
              # "8" = "󰲮";
              # "9" = "󰲰";
              # "10" = "󰿬";
              "special" = "⍟";

              "active" = "";
              "default" = "";
              "empty" = "";
            };
            "show-special" = true;
            "persistent-workspaces" = {
              "*" = 5;
            };
          };

          "hyprland/submap" = {
            "format" = "<span color='#a6da95'>Mode:</span> {}";
            "tooltip" = false;
          };

          "hyprland/window" = {
            "format" = "{title}";
            "max-length" = 30;
            "separate-outputs" = true;
            "icon" = true;
          };

          "clock#time" = {
            "format" = "{:%H:%M}";
            "tooltip" = false;
          };

          "custom/separator" = {
            "format" = "|";
            "tooltip" = false;
          };

          "custom/separator_dot" = {
            "format" = "•";
            "tooltip" = false;
          };

          "clock#week" = {
            "format" = "{:%a}";
            "tooltip" = false;
          };

          "clock#month" = {
            "format" = "{:%h}";
            "tooltip" = false;
          };

          "clock#calendar" = {
            "format" = "{:%d %h}";
            "tooltip-format" = "<tt><small>{calendar}</small></tt>";
            "actions" = {
              "on-click-right" = "mode";
            };
            "calendar" = {
              "mode"           = "month";
              "mode-mon-col"   = 3;
              "weeks-pos"      = "right";
              "on-scroll"      = 1;
              "on-click-right" = "mode";
              "format" = {
                "months" =     "<span color='#f4dbd6'><b>{}</b></span>";
                "days" =       "<span color='#cad3f5'><b>{}</b></span>";
                "weeks" =      "<span color='#c6a0f6'><b>W{}</b></span>";
                "weekdays" =   "<span color='#a6da95'><b>{}</b></span>";
                "today" =      "<span color='#8bd5ca'><b><u>{}</u></b></span>";
              };
            };
          };

          "clock" = {
            "format" = "{:%I:%M %p %Ez | %a • %h | %F}";
            "format-alt" = "{:%I:%M %p}";
            "tooltip-format" = "<tt><small>{calendar}</small></tt>";
            "actions" = {
              "on-click-right" = "mode";
            };
            "calendar" = {
              "mode"           = "month";
              "mode-mon-col"   = 3;
              "weeks-pos"      = "right";
              "on-scroll"      = 1;
              "on-click-right" = "mode";
              "format" = {
                "months" =     "<span color='#f4dbd6'><b>{}</b></span>";
                "days" =       "<span color='#cad3f5'><b>{}</b></span>";
                "weeks" =      "<span color='#c6a0f6'><b>W{}</b></span>";
                "weekdays" =   "<span color='#a6da95'><b>{}</b></span>";
                "today" =      "<span color='#8bd5ca'><b><u>{}</u></b></span>";
              };
            };
          };

          "network" = {
            "format" = "󰤭";
            "format-wifi" = "{icon}";
            "format-icons" = [ "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" ];
            "format-disconnected" = "󰤫 Disconnected";
            "tooltip-format" = "wifi <span color='#ee99a0'>off</span>";
            "tooltip-format-wifi" = "SSID: {essid}({signalStrength}%), {frequency} MHz\nInterface: {ifname}\nIP: {ipaddr}\nGW: {gwaddr}\n\n<span color='#a6da95'>{bandwidthUpBits}</span>\t<span color='#ee99a0'>{bandwidthDownBits}</span>\t<span color='#c6a0f6'>󰹹{bandwidthTotalBits}</span>";
            "tooltip-format-disconnected" = "<span color='#ed8796'>disconnected</span>";
            "format-ethernet" = "󰈁";
            "format-linked" = "󰈁 {ifname} (No IP)";
            "tooltip-format-ethernet" = "Interface: {ifname}\nIP: {ipaddr}\nGW: {gwaddr}\nNetmask: {netmask}\nCIDR: {cidr}\n\n<span color='#a6da95'>{bandwidthUpBits}</span>\t<span color='#ee99a0'>{bandwidthDownBits}</span>\t<span color='#c6a0f6'>󰹹{bandwidthTotalBits}</span>";
            "max-length" = 35;
            # "on-click" = "fish -c wifi_toggle";
            # "on-click-right" = "iwgtk";
          };

          "pulseaudio" = {
            "states" = {
              "high" = 89;
              "upper-medium" = 69;
              "medium" = 49;
              "lower-medium" = 29;
              "low" = 9;
            };
            "tooltip-format" = "{desc}";
            "format" = "{icon} {volume}% {format_source}";
            "format-bluetooth" = "{icon} {volume}% {format_source}";
            "format-bluetooth-muted" = "󰝟 {volume}% {format_source}";
            "format-muted" = "󰝟 {volume}% {format_source}";
            "format-source" = "󰍬 {volume}%";
            "format-source-muted" = "󰍭 {volume}%";
            "format-icons" = {
              "headphone" = "󰋋";
              "hands-free" = "";
              "headset" = "󰋎";
              "phone" = "󰄜";
              "portable" = "󰦧";
              "car" = "󰄋";
              "speaker" = "󰓃";
              "hdmi" = "󰡁";
              "hifi" = "󰋌";
              "default" = [ "󰕿" "󰖀" "󰕾" ];
            };
            "scroll-step" = 1;
            "on-click" = "pavucontrol";
            # "ignored-sinks" = ["Easy Effects Sink"]
          };

          "group/keyoard" = {
            "orientation" = "horizontal";
            "modules" = [
              "hyprland/language"
              "keyboard-state"
            ];
          };

          "hyprland/language" = {
            "format" = "  {}";
            "format-en" = "US";
            "format-no" = "NO";
          };

          "keyboard-state" = {
            "capslock" = true;
            # "numlock" = true;
            "format" = "{icon}";
            "format-icons" = {
              "locked" = "󰌎";
              "unlocked" = " ";
            };
          };

          "group/hardware" = {
            "orientation" = "horizontal";
            "modules" = [
              "cpu"
              "memory"
              "disk"
              "temperature"
            ];
          };

          "cpu" = {
            "format" = " ";
            "states" = {
              "high" = 90;
              "upper-medium" = 70;
              "medium" = 50;
              "lower-medium" = 30;
              "low" = 10;
            };
            "on-click" = "kitty btop";
            # "on-click-right" = "wezterm start btm";
          };

          "memory" = {
            "format" = " ";
            "tooltip-format" = "Main: ({used} GiB/{total} GiB)({percentage}%), available {avail} GiB\nSwap: ({swapUsed} GiB/{swapTotal} GiB)({swapPercentage}%), available {swapAvail} GiB";
            "states" = {
              "high" = 90;
              "upper-medium" = 70;
              "medium" = 50;
              "lower-medium" = 30;
              "low" = 10;
            };
            "on-click" = "kitty btop";
            # "on-click-right" = "wezterm start btm";
          };

          "disk" = {
            "format" = "󰋊 ";
            "tooltip-format" = "({used}/{total})({percentage_used}%) in '{path}', available {free}({percentage_free}%)";
            "states" = {
              "high" = 90;
              "upper-medium" = 70;
              "medium" = 50;
              "lower-medium" = 30;
              "low" = 10;
            };
            "on-click" = "kitty btop";
            # "on-click-right" = "wezterm start btm";
          };

          "temperature" = {
            "tooltip" = false;
            "thermal-zone" = 8;
            "critical-threshold" = 80;
            "format" = "{icon} {temperatureC}󰔄";
            "format-critical" = "🔥 {icon}{temperatureC}󰔄";
            "format-icons" = [ "" "" "" "" "" ];
          };

          "group/misc" = {
            "orientation" = "horizontal";
            "modules" = [
              "privacy"
              "custom/mako"
              "idle_inhibitor"
            ];
          };

          "privacy" = {
            "icon-spacing" = 1;
            "icon-size" = 12;
            "transition-duration" = 250;
            "modules" = [
              { "type" = "audio-in"; }
              { "type" = "screenshare"; }
            ];
          };

          "custom/mako" = {
            "return-type" = "json";
            "exec" = ./scripts/mako-widget;
            "format" = "{icon}";
            "format-icons" = {
              "enabled" = "󰂚";
              "disabled" = "󰂛";
            };
            "on-click" = "makoctl mode -t do-not-disturb";
            "interval" = "once";
          };

          "idle_inhibitor" = {
            "format" = "{icon}";
            "format-icons" = {
              "activated" = "󰛐";
              "deactivated" = "󰛑";
            };
            "tooltip-format-activated" = "Idle Inhibitor <span color='#a6da95'>on</span>";
            "tooltip-format-deactivated" = "Idle Inhibitor <span color='#ee99a0'>off</span>";
            "start-activated" = true;
          };

          "custom/logout_menu" = {
            "return-type" = "json";
            "exec" = "echo '{ \"text\":\"󰐥\", \"tooltip\": \"logout menu\" }'";
            "interval" = "once";
            "on-click" = "/home/otard/.config/power-menu.sh";
          };
        }
      ];

      style = builtins.replaceStrings
        [ "TEXT_FONT"        "TEXT_ICONS" ]
        [ theme.font.regular theme.font.icons ]
        ''
        @define-color rosewater #f2d5cf;
        @define-color flamingo #eebebe;
        @define-color pink #f4b8e4;
        @define-color mauve #ca9ee6;
        @define-color red #e78284;
        @define-color maroon #ea999c;
        @define-color peach #ef9f76;
        @define-color yellow #e5c890;
        @define-color green #a6d189;
        @define-color teal #81c8be;
        @define-color sky #99d1db;
        @define-color sapphire #85c1dc;
        @define-color blue #8caaee;
        @define-color lavender #babbf1;
        @define-color text #c6d0f5;
        @define-color subtext1 #b5bfe2;
        @define-color subtext0 #a5adce;
        @define-color overlay2 #949cbb;
        @define-color overlay1 #838ba7;
        @define-color overlay0 #737994;
        @define-color surface2 #626880;
        @define-color surface1 #51576d;
        @define-color surface0 #414559;
        @define-color base #303446;
        @define-color mantle #292c3c;
        @define-color crust #232634;

        * {
          border: none;
          font-family: TEXT_FONT;
        }

        window.top_bar#waybar {
          background: none;
        }

        window.top_bar .modules-left {
          background: none;
        }

        #workspaces {
          margin-left: 15px;
          background-color: alpha(@base, 0.7);
          border-radius: 36px;
        }

        #workspaces button {
          color: @text;
          font-size: 1.25rem;
          border-radius: 36px;
        }
        #workspaces button label {
          min-width: 15px;
        }

        #workspaces button.empty {
          color: @overlay0;
        }

        #workspaces button.active {
          color: @peach;
        }

        #window {
          margin-left: 15px;
          padding-left: 15px;
          padding-right: 15px;
          background-color: alpha(@base, 0.7);
          border-radius: 36px;
        }

        #submap {
          background-color: alpha(@surface1, 0.7);
          border-radius: 15;
          padding-left: 15;
          padding-right: 15;
          margin-left: 20;
          margin-right: 20;
          margin-top: 5;
          margin-bottom: 5;
        }

        window.top_bar .modules-center {
          font-weight: bold;
          background-color: alpha(@surface1, 0.7);
          color: @peach;
          border-radius: 15;
          padding-left: 20;
          padding-right: 20;
          margin-top: 5;
          margin-bottom: 5;
        }

        #custom-separator {
          color: @green;
        }

        #custom-separator_dot {
          color: @green;
        }

        #clock.time {
          color: @flamingo;
        }

        #clock.week {
          color: @sapphire;
        }

        #clock.month {
          color: @sapphire;
        }

        #clock.calendar {
          color: @mauve;
        }

        window.top_bar .modules-right {
          margin-right: 15px;
          background-color: alpha(@base, 0.7);
          border-radius: 36px;
          padding-left: 6px;
          padding-right: 6px;
        }

        #network {
          background-color: alpha(@surface1, 0.7);
          border-radius: 15;
          padding-left: 15;
          padding-right: 15;
          margin-left: 2;
          margin-right: 2;
          margin-top: 5;
          margin-bottom: 5;
        }

        #network.disabled {
          background-color: alpha(@surface0, 0.7);
          color: @subtext0;
        }

        #network.disconnected {
          color: @red;
        }

        #network.wifi {
          color: @teal;
        }

        #pulseaudio {
          background-color: alpha(@surface1, 0.7);
          border-radius: 15px;
          padding-left: 15px;
          padding-right: 15px;
          margin-left: 2px;
          margin-right: 6px;
          margin-top: 5px;
          margin-bottom: 5px;
        }

        #pulseaudio.bluetooth {
          color: @sapphire;
        }

        #pulseaudio.muted {
          color: @surface2;
        }

        #pulseaudio {
          color: @text;
        }

        #pulseaudio.low {
          color: @overlay0;
        }

        #pulseaudio.lower-medium {
          color: @overlay1;
        }

        #pulseaudio.medium {
          color: @overlay2;
        }

        #pulseaudio.upper-medium {
          color: @subtext0;
        }

        #pulseaudio.high {
          color: @subtext1;
        }

        #keyoard {
          background-color: alpha(@surface1, 0.7);
          border-radius: 15px;
          padding-left: 5px;
          padding-right: 5px;
          margin-left: 2px;
          margin-right: 6px;
          margin-top: 5px;
          margin-bottom: 5px;
        }

        #language {
          padding-left: 10px;
          padding-right: 5px;
        }

        #keyboard-state label.locked {
          color: @yellow;
        }

        #keyboard-state label {
          color: @subtext0;
        }

        #hardware {
          background-color: alpha(@surface1, 0.7);
          border-radius: 15;
          padding-left: 10;
          padding-right: 10;
          margin-left: 2;
          margin-right: 2;
          margin-top: 5;
          margin-bottom: 5;
        }

        #hardware label {
          margin-left: 10px;
        }

        #cpu {
          color: @sapphire;
        }

        #cpu.low {
          color: @rosewater;
        }

        #cpu.lower-medium {
          color: @yellow;
        }

        #cpu.medium {
          color: @peach;
        }

        #cpu.upper-medium {
          color: @maroon;
        }

        #cpu.high {
          color: @red;
        }

        #memory {
          color: @sapphire;
        }

        #memory.low {
          color: @rosewater;
        }

        #memory.lower-medium {
          color: @yellow;
        }

        #memory.medium {
          color: @peach;
        }

        #memory.upper-medium {
          color: @maroon;
        }

        #memory.high {
          color: @red;
        }

        #disk {
          color: @sapphire;
        }

        #disk.low {
          color: @rosewater;
        }

        #disk.lower-medium {
          color: @yellow;
        }

        #disk.medium {
          color: @peach;
        }

        #disk.upper-medium {
          color: @maroon;
        }

        #disk.high {
          color: @red;
        }

        #idle_inhibitor {
          margin-left: 2px;
          margin-right: 8px;
        }

        #idle_inhibitor.deactivated {
          color: @subtext0;
        }

        #custom-mako.inactive {
          color: @subtext0;
        }

        #custom-mako {
          margin-right: 2;
        }

        #custom-logout_menu {
          color: @red;
          background-color: alpha(@surface1, 0.7);
          border-radius: 15px;
          padding-left: 9px;
          padding-right: 9px;
          margin-top: 5px;
          margin-bottom: 5px;
        }


        #temperature {
          color: @green;
        }

        #temperature.critical {
          color: @red;
        }

        #battery {
          color: @teal;
        }

        #battery.low {
          color: @red;
        }

        #battery.lower-medium {
          color: @maroon;
        }

        #battery.medium {
          color: @peach;
        }

        #battery.upper-medium {
          color: @flamingo;
        }

        #battery.high {
          color: @rosewater;
        }

        #backlight {
          color: @overlay0;
        }

        #backlight.low {
          color: @overlay1;
        }

        #backlight.lower-medium {
          color: @overlay2;
        }

        #backlight.medium {
          color: @subtext0;
        }

        #backlight.upper-medium {
          color: @subtext1;
        }

        #backlight.high {
          color: @text;
        }

        #systemd-failed-units {
          color: @red;
        }
      '';
    };
  };

}
