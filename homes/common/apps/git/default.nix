{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.programs.git;
in {
  config = mkIf cfg.enable {
    programs.git.settings = {
      init.defaultBranch = mkDefault "master";
      pull.rebase = mkDefault true;
      core.editor = mkDefault "emacsclient -t -a emacs";
      push.autoSetupRemote = mkDefault true;

      color = {
        ui = "auto";
        branch = "auto";
        diff = "auto";
        interactive = "auto";
        status = "auto";
      };

      commit.verbose = mkDefault true;
      branch.autosetuprebase = mkDefault "always";
      push.default = mkDefault "simple";
      rebase = {
        autoSquash = mkDefault true;
        autoStash = mkDefault true;
      };
    };
  };
}
