{ lib
, rustPlatform
, btrfs-progs
}:
rustPlatform.buildRustPackage {
  name = "btrfs-rollback";
  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [ rustPlatform.bindgenHook ];
  buildInputs = [ btrfs-progs ];

  meta = {
    description = "Rollback btrfs subvolume to a snapshot";
    license = lib.licenses.unlicense;
    maintainers = [ lib.maintainers.tie ];
    platforms = lib.platforms.linux;
    mainProgram = "btrfs-rollback";
  };
}
