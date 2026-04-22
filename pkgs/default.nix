pkgs: {
  sddm-theme = pkgs.sddm-astronaut.override { embeddedTheme = "jake_the_dog"; };
  control_modules = pkgs.callPackage ./control_modules { };
}
