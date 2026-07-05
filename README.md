# kmod

[kmod](https://git.kernel.org/pub/scm/utils/kernel/kmod/kmod.git) — a single self-contained binary that provides the `modprobe`, `depmod`, `insmod`, `lsmod`, `modinfo`, and `rmmod` programs, built natively for Linux.

[![CI](https://github.com/unpins/kmod/actions/workflows/kmod.yml/badge.svg)](https://github.com/unpins/kmod/actions)
![Linux](https://img.shields.io/badge/Linux-✓-success?logo=linux&logoColor=white)

Part of the [unpins](https://unpins.org) catalog; install it with [`unpin`](https://github.com/unpins/unpin): `unpin install kmod`.

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

`unpin install kmod` creates the `modprobe`, `depmod`, `lsmod`, `modinfo`, … commands (full list: `unpin info kmod`).

## Man pages

The man pages are embedded in the binary — read with `unpin man kmod`. Covers the program pages (`kmod.8`, `modprobe.8`, `depmod.8`, `insmod.8`, `lsmod.8`, `modinfo.8`, `rmmod.8`) and the config/format pages (`modprobe.d.5`, `depmod.d.5`, `modules.dep.5`).

## Build notes

- **Every upstream feature enabled.** Module decompression for all three
  backends — `zstd`, `xz` and `zlib` (gzip `.ko.gz`) — plus `openssl`/libcrypto
  for PKCS#7 module-signature parsing (`modinfo` signature output). nixpkgs'
  stock kmod wires only xz+zstd; this build adds zlib and openssl so nothing
  upstream supports is dropped. openssl (not the project's usual mbedtls)
  because kmod's signature code is written against the openssl API. (On armv7l,
  static `libcrypto` used to propagate a bare `-latomic` that a static-musl +
  compiler-rt toolchain can't resolve; that's stripped from openssl's `.pc` in
  nix-lib now, so kmod links clean with no per-package workaround.)

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

## Manual download

The [Releases](https://github.com/unpins/kmod/releases) page has standalone binaries for manual download.
