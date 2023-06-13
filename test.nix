{ lib, ... }: {
  name = "btrfs-restore";

  nodes.machine = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.btrfs-restore ];
  };

  # TODO: create filesystem and check edge cases (e.g. `..` in paths,
  # removing root subvolume, etc).
  testScript = ''
    start_all()
    machine.wait_for_unit("multi-user.target")
    machine.succeed("btrfs-restore --help")
  '';

  meta.maintainers = [ lib.maintainers.tie ];
}
