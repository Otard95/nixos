{ pkgs, ... }:
{
  enable = true;

  shellAliases = {
    ll = "ls -lah";
    ".." = "cd ..";
  };
}
