{ lib
, rustPlatform
, btrfs-progs
}:
rustPlatform.buildRustPackage {
  name = "btrfs-rollback";
  src = ./.;

  cargoHash = "sha256-AljqhBLVMjGExy3aO7FpBRbiih8nfbXzSi/nP0DUXk0=";

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
