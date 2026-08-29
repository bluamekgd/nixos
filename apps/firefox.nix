{
  inputs,
  pkgs,
  ...
}: {

  nixpkgs.config.packageOverrides = pkgs: {
    nur = import inputs.nur {
      inherit pkgs;
    };
  };

  programs.firefox = {
    enable = true;

    profiles.default = {
      id = 0;
      isDefault = true;

      extraConfig = builtins.readFile "${pkgs.arkenfox}/user.js";

      settings = {
        "extenisons.autoDisableScopes" = 0;
      };

      extensions.packages = {
        adnauseam
	bitwarden
	darkreader
	consentomatic
      };
    };
  };

}
