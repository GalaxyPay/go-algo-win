# go-algo-win

Automated Windows builds of the [Algorand node software](https://github.com/algorand/go-algorand) (`algod`, `goal`, `kmd`, and friends).

## Why

Algorand publishes official node binaries for Linux and macOS, but not for Windows. This repository fills that gap so Windows users can run a native node without WSL, Docker, or building go-algorand themselves. The archives are consumed by [FUNC](https://github.com/GalaxyPay/func), which verifies each download against the published SHA-256 checksum before installing it.

These builds are **unofficial**. The source is the upstream go-algorand code, unmodified — this repo only contains the build pipeline. For what changed in a given version, always read the corresponding [go-algorand release notes](https://github.com/algorand/go-algorand/releases); each release here links to its upstream counterpart.

## Download

Grab `node.tar.gz` from the [Releases](https://github.com/GalaxyPay/go-algo-win/releases) page. Release tags match upstream tags exactly (e.g. `v5.1.1-stable`). The archive contains a `bin/` folder with:

`algod.exe` · `goal.exe` · `kmd.exe` · `algokey.exe` · `algocfg.exe` · `diagcfg.exe` · `catchpointdump.exe` · `msgpacktool.exe` · `netgoal.exe`

Verify the download against `node.tar.gz.sha256` (also shown in the release notes):

```powershell
(Get-FileHash node.tar.gz -Algorithm SHA256).Hash
```

## How it works

go-algorand is pinned as a git submodule at [`go-algorand/`](go-algorand). Two GitHub Actions workflows keep it current and produce releases:

1. **[Bump go-algorand](.github/workflows/bump-go-algorand.yml)** — runs every 10 minutes. It looks up the newest `vX.Y.Z-stable` tag on upstream, and if the submodule isn't already on that commit, opens a PR (`bump/go-algorand-<tag>`) that moves the submodule pointer to it.
2. **[Build](.github/workflows/build.yml)** — runs on every push to `main` (i.e. when a bump PR is merged) or manually. On a `windows-latest` runner with MSYS2 (UCRT64 toolchain), it:
   - runs [`ci-build.sh`](ci-build.sh), which downloads Go, patches go-algorand's `scripts/configure_dev.sh` to use MSYS2 UCRT64 package names (the Go source itself is untouched), installs build dependencies, and runs `make install`;
   - packages the binaries into `node.tar.gz` and writes its SHA-256 checksum;
   - creates a GitHub release named after the submodule's exact go-algorand tag, with release notes linking to the upstream release and commit. Releases are immutable — an existing tag is never overwritten.

So the normal flow is: upstream tags a stable release → a bump PR appears here → a maintainer reviews and merges it → the Windows build is published automatically.

## Building locally

From an MSYS2 **UCRT64** shell with `git`, `unzip`, and `mingw-w64-ucrt-x86_64-gcc` installed:

```sh
git clone --recurse-submodules https://github.com/GalaxyPay/go-algo-win.git
cd go-algo-win
./ci-build.sh
```

The output is `node.tar.gz` in the repo root. Note that the script downloads Go into the working directory and edits files inside the submodule.

## License

The compiled binaries are built from go-algorand and are subject to its [license](https://github.com/algorand/go-algorand/blob/master/COPYING) (AGPL-3.0).
