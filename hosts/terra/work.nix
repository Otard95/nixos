{ ... }:
{
  modules = {
    nixvim.enable = true;
    packages = {
      docker.enable = true;
      apps = {
        matrix.enable = true;
        slack.enable = true;
      };
    };
  };
}
