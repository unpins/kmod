# kmod

Standalone build of [kmod](https://git.kernel.org/pub/scm/utils/kernel/kmod/kmod.git), shipped as a single multicall binary that dispatches to `modprobe`, `depmod`, `insmod`, `lsmod`, `modinfo`, and `rmmod` via argv[0].

[![CI](https://github.com/unpins/kmod/actions/workflows/kmod.yml/badge.svg)](https://github.com/unpins/kmod/actions)
![Linux](https://img.shields.io/badge/Linux-✓-success?logo=linux&logoColor=white)

Part of the [unpins](https://unpins.org) project — native single-binary builds with no third-party runtime dependencies.

Linux-only: kmod loads and inspects Linux kernel modules and talks to `/sys/module`, `/proc/modules`, and the `init_module`/`finit_module`/`delete_module` syscalls.

## Usage

The package ships one executable, `kmod`. `unpin kmod` materializes per-applet shims (`modprobe`, `depmod`, `insmod`, `lsmod`, `modinfo`, `rmmod`) next to the multicall using argv[0] dispatch. To run a command directly without installing, invoke as `kmod <applet>`:

```bash
kmod modprobe ext4
kmod depmod -a
kmod lsmod
kmod modinfo ext4
```

Or create symlinks named after the commands you want to use as bare names:

```bash
ln -s "$(command -v kmod)" ~/bin/modprobe
modprobe ext4
```

Built-in applets: `depmod`, `insmod`, `lsmod`, `modinfo`, `modprobe`, `rmmod`.

## Installation

Install with [unpin](https://github.com/unpins/unpin):

```bash
unpin kmod
```

Or run without installing:

```bash
unpin run kmod
```

## Build locally

```bash
nix build github:unpins/kmod
./result/bin/kmod modprobe ext4
```

Or run directly:

```bash
nix run github:unpins/kmod -- modprobe ext4
```

The first invocation will offer to add the [unpins.cachix.org](https://unpins.cachix.org) substituter so most pulls come pre-built.

## Man pages

The man pages are embedded in the binary — read with `unpin man kmod`. Covers the applet pages (`kmod.8`, `modprobe.8`, `depmod.8`, `insmod.8`, `lsmod.8`, `modinfo.8`, `rmmod.8`) and the config/format pages (`modprobe.d.5`, `depmod.d.5`, `modules.dep.5`).

## Manual download

The [Releases](https://github.com/unpins/kmod/releases) page has standalone binaries for manual download.
