{ lib, ... }: {
  name = "btrfs-rollback";

  nodes.machine = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.btrfs-rollback ];
  };

  # TODO: create filesystem and check edge cases (e.g. `..` in paths,
  # removing root subvolume, etc).
  testScript = ''
    start_all()
    machine.wait_for_unit("multi-user.target")
    machine.succeed("btrfs-rollback --help")
  '';

  meta.maintainers = [ lib.maintainers.tie ];
}
