{ pkgs, ... }:
{
  minecraft = pkgs.fetchFromGitHub {
      owner = "Lxtharia";
      repo = "minegrub-theme";
      rev = "987408b8d2cbf0a79a15981788d423fc3e54a80f";
      sha256 = "1pp4nvcf4grsykwilyrqxf6mvicdjcf83823j6llwhxn3gzxyz8w";
    };
    installPhase = "cp -r customize/nixos $out";
  fallout = pkgs.fetchFromGitHub
  {
    owner = "shvchk";
    repo = "fallout-grub-theme";
    rev = "80734103d0b48d724f0928e8082b6755bd3b2078";
    sha256 = "sha256-7kvLfD6Nz4cEMrmCA9yq4enyqVyqiTkVZV5y4RyUatU=";
  };
}
