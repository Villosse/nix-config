{ inputs, ... }:
{
  programs.git = {
    enable = true;
    userEmail = "lenny.chiadmi-delage@epita.fr";
    userName = "lenny.chiadmi-delage";
    extraConfig = {
      core = { editor = "vim"; };
    };
  };
}
