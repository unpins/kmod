# Changelog

## [Unreleased]

### Added

- `modinfo` now reports who signed a module and how. Against a stock Debian
  kernel module, the v31-1 release printed `sig_id: PKCS#7` and then left
  `signer`, `sig_key` and `signature` blank with `sig_hashalgo: unknown`; those
  fields are filled in now. This is what libcrypto is linked in for, and it is
  most of the size below.
- Modules compressed with gzip (`.ko.gz`) load and are read. The v31-1 release
  handled only `.ko.xz` and `.ko.zst`. `kmod --version` lists what is compiled
  in: `+ZSTD +XZ +ZLIB +LIBCRYPTO`, against `+ZSTD +XZ -ZLIB -LIBCRYPTO` before.

### Fixed

- `unpin install kmod` now creates the commands. In the v31-1 release it
  created only `kmod` itself: the list of program names never made it into the
  published binary, so `modprobe`, `depmod`, `insmod`, `lsmod`, `modinfo` and
  `rmmod` were installed nowhere.

### Changed

- The binary grew from 520 KB to 4.3 MB. Measured piece by piece: gzip support
  costs 57 KB and the signature parsing costs 3.7 MB, which is what a static
  libcrypto weighs. Checked on Linux x86_64 and arm64: `lsmod` lists the loaded
  modules, `modinfo` reads `.ko.xz` and prints the signature, and `kmod list`
  and `kmod static-nodes` work.
