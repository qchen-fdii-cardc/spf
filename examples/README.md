# FFI Examples

Build the dynamic library first:

```bash
cargo build --release --package spf
```

Expected output (Linux): `target/release/libspf.so`

## CMake (C/C++)

From project root:

```bash
cmake -S examples -B examples/build
cmake --build examples/build
./examples/build/c_demo
./examples/build/cpp_demo
```

This uses `examples/CMakeLists.txt` and links against the Rust dynamic library from `target/release`.

## C Example

Source: `examples/c/main.c`

Build and run (Linux):

```bash
gcc examples/c/main.c -Iinclude -Ltarget/release -lspf -o examples/c/c_demo
LD_LIBRARY_PATH=target/release ./examples/c/c_demo
```

## C++ Example

Source: `examples/cpp/main.cpp`

Build and run (Linux):

```bash
g++ examples/cpp/main.cpp -Iinclude -Ltarget/release -lspf -o examples/cpp/cpp_demo
LD_LIBRARY_PATH=target/release ./examples/cpp/cpp_demo
```

## Python Example

Source: `examples/python/example.py`

Run:

```bash
python3 examples/python/example.py
```

The script auto-detects:
- Linux: `libspf.so`
- macOS: `libspf.dylib`
- Windows: `spf.dll`

## MATLAB Example

Source: `examples/matlab/example.m`

Run in MATLAB:

```matlab
example
```

If there is a name conflict with MATLAB built-ins, run by path:

```matlab
run('examples/matlab/example.m')
example
```
