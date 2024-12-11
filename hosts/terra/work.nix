{ ... }:
{
  modules = {
    nixvim.enable = true;
    packages = {
      docker.enable = true;
      apps = {
        _1password.enable = true;
        clickup.enable = true;
        matrix.enable = true;
        slack.enable = true;
      };
    };
  };
}
