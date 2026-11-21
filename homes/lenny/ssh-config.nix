{...}: {
  programs.ssh.settings."home-nas 192.168.1.106" = {
    HostName = "192.168.1.106";
    User = "lenny";
    SetEnv.TERM = "xterm-256color";
  };
}
