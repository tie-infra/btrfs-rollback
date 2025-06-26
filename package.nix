{ lib
, rustPlatform
, btrfs-progs
}:
rustPlatform.buildRustPackage {
  name = "btrfs-rollback";
  src = ./.;

  cargoHash = "sha256-XUOEbJy9R9F0jOiHKMHaFZQO1B/Zeh7/FJGR+Ku6eXo=";

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
