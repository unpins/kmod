# kmod

Standalone build of [kmod](https://git.kernel.org/pub/scm/utils/kernel/kmod/kmod.git), shipped as a single binary that provides the `modprobe`, `depmod`, `insmod`, `lsmod`, `modinfo`, and `rmmod` programs.

[![CI](https://github.com/unpins/kmod/actions/workflows/kmod.yml/badge.svg)](https://github.com/unpins/kmod/actions)
![Linux](https://img.shields.io/badge/Linux-✓-success?logo=linux&logoColor=white)

Part of the [unpins](https://unpins.org) project — native single-binary builds with no third-party runtime dependencies.

Linux-only: kmod loads and inspects Linux kernel modules and talks to `/sys/module`, `/proc/modules`, and the `init_module`/`finit_module`/`delete_module` syscalls.

## Usage

Run a program with [unpin](https://github.com/unpins/unpin):

```bash
unpin kmod modprobe ext4
unpin kmod depmod -a
unpin kmod lsmod
unpin kmod modinfo ext4
```

To install the programs onto your PATH:

```bash
unpin install kmod
```

`unpin install kmod` creates the `modprobe`, `depmod`, `insmod`, `lsmod`, `modinfo`, and `rmmod` commands.

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
