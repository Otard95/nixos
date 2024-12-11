{ ... }:
{
  modules = {
    nixvim.enable = true;
    packages = {
      docker.enable = true;
      apps = {
        _1password.enable = true;
        appgate.enable = true;
        clickup.enable = true;
        dbeaver.enable = true;
        matrix.enable = true;
        slack.enable = true;
      };
    };
  };
}
