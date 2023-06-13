{ lib
, rustPlatform
, btrfs-progs
}:
rustPlatform.buildRustPackage {
  name = "restore-btrfs";
  src = ./.;

  cargoHash = "sha256-x1NDcjqE1+u2fGIXhPZg9w9S/ChgWHXyKO2OO29dw5M=";

  nativeBuildInputs = [ rustPlatform.bindgenHook ];
  buildInputs = [ btrfs-progs ];

  meta = {
    description = "Restore btrfs subvolume from snapshot";
    license = lib.licenses.unlicense;
    maintainers = [ lib.maintainers.tie ];
    platforms = lib.platforms.linux;
    mainProgram = "btrfs-restore";
  };
}
