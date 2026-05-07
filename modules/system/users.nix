{ ... }:
{
  users = {
    users.otard = {
      isNormalUser = true;
      description = "Stian";
      extraGroups = [ "networkmanager" "wheel" "input" ];
      # packages = with pkgs; [];
    };
  };
}
