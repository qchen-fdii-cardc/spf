import ctypes
import platform
from pathlib import Path


def load_library() -> ctypes.CDLL:
    root = Path(__file__).resolve().parents[2]
    lib_name = {
        "Linux": "libspf.so",
        "Darwin": "libspf.dylib",
        "Windows": "spf.dll",
    }.get(platform.system())
    if lib_name is None:
        raise RuntimeError(f"Unsupported OS: {platform.system()}")

    lib_path = root / "target" / "release" / lib_name
    if not lib_path.exists():
        raise FileNotFoundError(f"Library not found: {lib_path}")

    return ctypes.CDLL(str(lib_path))


lib = load_library()
lib.spf_lambda.argtypes = [ctypes.c_double]
lib.spf_lambda.restype = ctypes.c_double
lib.spf_hydraulic_diameter.argtypes = [ctypes.c_double, ctypes.c_double]
lib.spf_hydraulic_diameter.restype = ctypes.c_double
lib.spf_kp_rect.argtypes = [ctypes.c_double, ctypes.c_double, ctypes.c_double]
lib.spf_kp_rect.restype = ctypes.c_double

re = 2500.0
print(f"Re = {re}")
print(f"lambda = {lib.spf_lambda(re):.6f}")
print(f"hydraulic diameter = {lib.spf_hydraulic_diameter(0.2, 0.1):.6f}")
print(f"kp_rect = {lib.spf_kp_rect(re, 0.2, 0.1):.6f}")
