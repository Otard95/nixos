{ lib, pkgs, helpers, ... }:
let
  mkOption = helpers.mkOption;

  configFormat = pkgs.formats.libconfig {};

  noneActionType = with lib.types; submodule {
    options = {
      type = lib.mkOption { type = enum ["None"]; };
    };
  };

  keypressActionType = with lib.types; submodule {
    options = {
      type = lib.mkOption { type = enum ["Keypress"]; };
      keys = lib.mkOption {
        description = ''
          This is a required list of strings/integers that defines the
          keys to be pressed/released. For a list of key/button strings, refer
          to [linux/input-event-codes.h](https://github.com/torvalds/linux/blob/master/include/uapi/linux/input-event-codes.h). (e.g. keys: ["KEY_A", "KEY_B"];).
          Alternatively, you may use integer keycodes to define the keys.

          Please note that these event codes work in a US (QWERTY) keyboard
          layout. If you have a locale set that does not use this keyboard
          layout, please map it to whatever key it would be on a QWERTY
          keyboard. (e.g. "KEY_Z" on a QWERTZ layout should be "KEY_Y")
        '';
        type = coercedTo (listOf (oneOf [ints.positive str])) configFormat.lib.mkArray anything;
      };
    };
  };

  toggleSmartShiftActionType = with lib.types; submodule {
    options = {
      type = lib.mkOption { type = enum ["ToggleSmartShift"]; };
    };
  };

  nonGestureActionType = with lib.types; oneOf [ noneActionType keypressActionType toggleSmartShiftActionType ];

  gestureActionType = with lib.types; submodule {
    options = {
      type = lib.mkOption { type = enum ["Gestures"]; };
      gestures = listOf (submodule {
        direction = lib.mkOption { type = enum ["Up" "Down" "Left" "Right" "None"]; };
        threshold = lib.mkOption { type = ints.positive; default = 50; };
        mode = lib.mkOption { type = enum [ "NoPress" "OnRelease" "OnInterval" "OnThreshold" "Axis" ]; };
        axis = lib.mkOption { type = nullOr str; default = null; };
        axis_multiplier = lib.mkOption { type = nullOr ints.positive; default = null; };
        action = lib.mkOption { type = nullOr nonGestureActionType; default = null; };
      });
    };
  };

  actionType = with lib.types; oneOf [ noneActionType keypressActionType toggleSmartShiftActionType gestureActionType ];

  filterDeep = 
    pred: value:

    if lib.isAttrs value then
      # Recurse into attribute sets
      lib.listToAttrs (
        lib.concatMap
        (name:
          let v = value.${name};
          in
            if pred name v then
            [ (lib.nameValuePair name (filterDeep pred v)) ]
          else
            [ ]
        )
        (lib.attrNames value)
      )

    else if lib.isList value then
      # Recurse into lists
      lib.map (v: filterDeep pred v)
      (lib.filter (v: pred null v) value)

    else
      # Primitive value → keep as-is
      value;
in {
  filterDeep = filterDeep;

  settings-type = with lib.types; submodule {
    options = {

      ignore = mkOption.listOf "Ignored device PIDs" str;

      devices = mkOption.listOf "A list of device configurations" (submodule {
        options = {
          name = mkOption.str "The name of the device to configure";

          dpi = mkOption.optional (lib.mkOption {
            description = "The mouse DPI, or list of DIPs if it has more than one sensor";
            type = either ints.positive (listOf ints.positive);
          });

          smartshift = mkOption.optional (
            mkOption.submodule "SmartShift settings for a mouse that supports it." {
              on = mkOption.optional (mkOption.bool "Should mouse wheel be high resolution or not.");
              threshold = mkOption.optional (mkOption.ints.u8 "Threshold required to change the SmartShift wheel to free-spin.");
              default_threshold = mkOption.optional (mkOption.ints.u8 "Default threshold required to change the SmartShift wheel to free-spin.");
            }
          );

          hiresscroll = mkOption.optional (
            mkOption.submodule "HiRes mouse-scrolling settings for a device that supports it." {
              hires = mkOption.optional (mkOption.bool "Should mouse wheel be high resolution or not.");
              invert = mkOption.optional (mkOption.bool "Should mouse wheel be inverted or not.");
              target = mkOption.optional (mkOption.bool ''
                Should mousewheel events send as an HID++ notification or work normally (true for HID++ notification, false for normal usage).
                This option must be set to true to remap the scroll wheel action.
              '');
              up = mkOption.optional (lib.mkOption {
                description = "The gesture/action that will be taken when the scroll wheel is moved up (down if inverted).";
                type = actionType;
              });
              down = mkOption.optional (lib.mkOption {
                description = "The gesture/action that will be taken when the scroll wheel is moved down (up if inverted).";
                type = actionType;
              });
            }
          );

          thumbwheel = mkOption.optional (
            mkOption.submodule "Thumb wheel settings on a device that supports it." {
              divert = mkOption.optional (mkOption.bool "Should thumb wheel be handled by logid (true) or the OS (false).");
              invert = mkOption.optional (mkOption.bool "Should thumb wheel be inverted or not.");
              left = mkOption.optional (lib.mkOption {
                description = "The gesture/action that will be taken when the scroll wheel is moved left (right if inverted).";
                type = actionType;
              });
              right = mkOption.optional (lib.mkOption {
                description = "The gesture/action that will be taken when the scroll wheel is moved right (letf if inverted).";
                type = actionType;
              });
            }
          );

          buttons = mkOption.listOf "A list of button mappings" (submodule {
            options = {

              cid = lib.mkOption {
                description = ''
                The `cid` of the button to configure. You can find a list here:
                https://github.com/PixlOne/logiops/wiki/CIDs
                '';
                type = coercedTo (strMatching "0x[0-9a-fA-F]{2}(?:[0-9a-fA-F]{2})?") configFormat.lib.mkHex anything;
              };

              action = lib.mkOption {
                description = "What the button should do";
                type = actionType;
              };

            };
          });
        };
      });

    };
  };

  preset = {
    sensibleMXMaster4 = {
      devices = [ { name = "MX Master 4"; thumbwheel.invert = true; } ];
    };
  };
}
