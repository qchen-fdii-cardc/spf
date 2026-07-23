# spf: Smooth Pipe Friction Calculator

A small Rust library for flow/friction calculations with FFI support.

## Features

- Compute Darcy friction factor (`lambda`) over laminar, transition, and turbulent ranges.
- Compute hydraulic diameter for rectangular channels.
- Compute rectangular correction factor (`kp_rect`).
- Build as a Rust library and as a dynamic library for C/C++/Python/MATLAB.

## Build

```bash
cargo build
```

Release build (recommended for FFI use):

```bash
cargo build --release --package spf
```

## Test

```bash
cargo test --package spf --lib
```

## Dynamic Library Output

With release build, artifacts are generated under `target/release`:

- Linux: `libspf.so`
- macOS: `libspf.dylib`
- Windows: `spf.dll`

Public C ABI declarations are in `include/spf.h`.

## FFI Function Names

- `spf_lambda(double re)`
- `spf_hydraulic_diameter(double a, double b)`
- `spf_kp_rect(double re, double a0, double b0)`

## Examples

See language examples under `examples`:

- C: `examples/c/main.c`
- C++: `examples/cpp/main.cpp`
- Python: `examples/python/example.py`
- MATLAB: `examples/matlab/example.m`
- CMake entry for C/C++: `examples/CMakeLists.txt`

Quick start for examples:

```bash
cmake -S examples -B examples/build
cmake --build examples/build
./examples/build/c_demo
./examples/build/cpp_demo
python3 examples/python/example.py
```

For more details, see `examples/README.md`.
