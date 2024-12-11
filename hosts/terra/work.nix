{ ... }:
{
  modules = {
    nixvim.enable = true;
    packages = {
      docker.enable = true;
      apps = {
        matrix.enable = true;
      };
    };
  };
}
