{
  images = let
    data    = builtins.fromJSON (builtins.readFile ./images.json);
    mkGroup = group: builtins.listToAttrs (map (img: {
      name  = img.file;
      value = builtins.fetchurl {
        url    = group.baseUrl + img.file + "." + (img.ext or group.ext);
        sha256 = img.sha256;
      };
    }) group.images);
  in {
    background = {
      catppuccin = mkGroup data.catppuccin;
      cloud-mountain-snow   = ./background-images/cloud-mountain-snow.png;
      falling-into-infinity = ./background-images/falling-into-infinity.png;
      forrest-lake-train    = ./background-images/forrest-lake-train.png;
      mountain-lake-sunrise = ./background-images/mountain-lake-sunrise.png;
      astronaut             = ./background-images/astronaut.png;
      astronaut-vertical    = ./background-images/astronaut-vertical.png;
    };
    splash = {
      bridge-forrest-fog  = ./splash-images/bridge-forrest-fog.jpg;
      lynnette-space-suit = ./splash-images/lynnette-space-suit.jpg;
      spacegirl           = ./splash-images/spacegirl.jpg;
      black-hole          = ./splash-images/black-hole.png;
    };
  };
}
