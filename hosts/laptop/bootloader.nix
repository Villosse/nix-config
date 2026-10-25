{ ... }: {

boot.loader.systemd-boot.enable = true;
# Keep the menu short so Windows sits near the top; 2 keeps one rollback entry
boot.loader.systemd-boot.configurationLimit = 2;
# Windows lives on its own ESP (nvme1n1p1); handle found with `map -c` in the EFI shell
boot.loader.systemd-boot.windows."11" = {
  title = "Windows 11";
  efiDeviceHandle = "HD1b";
};
boot.loader.efi.canTouchEfiVariables = true;

}
