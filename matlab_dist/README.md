# SPF MATLAB Toolbox Distribution

This folder contains the MATLAB toolbox layout for packaging SPF as an `.mltbx`.

## Folder Layout

- `+spf/` MATLAB package API
- `bin/<arch>/` platform library (`spf.dll`, `libspf.so`, `libspf.dylib`)
- `include/spf.h` C header used by `loadlibrary`
- `prepare_binaries.m` copies built artifacts from this repo
- `build_mltbx.m` packages this folder into `.mltbx`
- `auto_release_mltbx.m` one-command release packaging script

## Build And Package

1. Build the native library from repo root:

   `cargo build --release`

2. In MATLAB, run:

   `cd matlab_dist`

   `prepare_binaries`

3. Package `.mltbx`:

   `outFile = build_mltbx`

## Auto Release Script

For CI or one-command local release, run:

`artifactFile = auto_release_mltbx`

Optional arguments:

- `artifactFile = auto_release_mltbx(outDir)`
- `artifactFile = auto_release_mltbx(outDir, runCargoBuild)`

Example skipping cargo build when artifacts are already built:

`artifactFile = auto_release_mltbx('dist', false)`

On success, the script writes:

- `dist/spf_matlab_<version>.mltbx`
- `dist/release_manifest.txt`

The script fails fast if MATLAB lacks `matlab.addons.toolbox.packageToolbox`.

If your MATLAB release does not support programmatic packaging, use:

- MATLAB UI: **APPS > Package Toolbox**
- Source folder: `matlab_dist`
- Output file: `dist/spf_matlab_<version>.mltbx`

## Install

- GUI: double-click the generated `.mltbx`
- CLI: `matlab.addons.toolbox.installToolbox('path/to/spf_matlab_<version>.mltbx')`

## Use

After install:

- `spf.lambda(re)`
- `spf.hydraulicDiameter(a, b)`
- `spf.kpRect(re, a0, b0)`
