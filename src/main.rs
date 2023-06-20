use anyhow::{ensure, Context, Result};
use clap::{Parser, ValueHint};
use libbtrfsutil::{
    create_snapshot, delete_subvolume, is_subvolume, CreateSnapshotFlags, DeleteSubvolumeFlags,
};
use nix::mount::{mount, umount, MsFlags};
use path_clean::PathClean;
use std::fs::create_dir_all;
use std::path::{Path, PathBuf};

#[derive(Parser, Debug)]
struct Args {
    /// Btrfs device path to mount.
    #[clap(short, long, value_hint = ValueHint::FilePath)]
    device_path: PathBuf,

    /// Mount options for the btrfs filesystem.
    #[clap(short, long)]
    options: Option<PathBuf>,

    /// Temporary mountpoint for btrfs filesystem. If the specified path does
    /// not exist, it will be created, including intermediate directories, and
    /// will not be removed after exit.
    #[clap(short, long, value_hint = ValueHint::DirPath)]
    mountpoint: PathBuf,

    /// Btrfs subvolume to delete recursively.
    #[clap(short, long)]
    subvolume: PathBuf,

    /// Btrfs snapshot for subvolume rollback.
    #[clap(short, long)]
    snapshot: PathBuf,
}

fn main() -> Result<()> {
    let args = Args::parse();

    create_dir_all(&args.mountpoint).context("Failed to create directory for filesystem mount")?;

    mount(
        Some(&args.device_path),
        &args.mountpoint,
        Some("btrfs"),
        MsFlags::empty(),
        args.options.as_ref(),
    )
    .context("Failed to mount filesystem")?;

    let result = rollback_snapshot(&args.mountpoint, &args.subvolume, &args.snapshot);
    unmount(&args.mountpoint);
    result
}

fn rollback_snapshot(mountpoint: &Path, subvolume: &Path, snapshot: &Path) -> Result<()> {
    let subvolume_path = mountpoint.join(subvolume.clean());
    let snapshot_path = mountpoint.join(snapshot.clean());

    // NB we lexicographically clean the subvolume paths above before joining
    // them with mountpoint, so they should be on the same underlying btrfs
    // filesystem.
    //
    // As an additional check, we also ensure that we have a subvolume to
    // rollback to before deleting everything.

    ensure_subvolume(&snapshot_path)?;

    delete_subvolume(&subvolume_path, DeleteSubvolumeFlags::RECURSIVE)
        .context("Failed to recursively delete subvolume")?;

    create_snapshot(
        snapshot_path,
        subvolume_path,
        CreateSnapshotFlags::RECURSIVE,
        None,
    )
    .context("Failed to recursively rollback to snapshot")
}

fn ensure_subvolume(path: &Path) -> Result<()> {
    ensure!(
        is_subvolume(path).context("Failed to check whether snapshot is a subvolume")?,
        "snapshot path is not a subvolume",
    );
    Ok(())
}

fn unmount(mountpoint: &Path) {
    let result = umount(mountpoint).context("Failed to unmount filesystem");
    if let Err(e) = result {
        eprintln!("{}", e);
    }
}
