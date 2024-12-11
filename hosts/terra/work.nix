{ ... }:
{
  modules = {
    nixvim.enable = true;
    packages = {
      docker.enable = true;
      apps = {
        clickup.enable = true;
        matrix.enable = true;
        slack.enable = true;
      };
    };
  };
}
