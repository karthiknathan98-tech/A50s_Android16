#!/usr/bin/env python3
"""
make_vbmeta.py
Generates an AVB 2.0 disabled vbmeta image for Samsung Exynos devices.
Sets AVB_VBMETA_IMAGE_FLAGS_HASHTREE_DISABLED | AVB_VBMETA_IMAGE_FLAGS_VERIFICATION_DISABLED (flags = 2).
"""

import sys
import struct
from pathlib import Path

def generate_disabled_vbmeta(output_path: Path):
    header = bytearray(4096)
    # Magic bytes 'AVB0'
    header[0:4] = b"AVB0"
    # Format version: major=1, minor=0
    struct.pack_into(">II", header, 4, 1, 0)
    # Flags = 2 at byte offset 120 (0x78)
    struct.pack_into(">I", header, 120, 2)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "wb") as f:
        f.write(header)
    print(f"[✓] Created disabled AVB 2.0 vbmeta image at {output_path} ({len(header)} bytes)")

if __name__ == "__main__":
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("vbmeta_disabled.img")
    generate_disabled_vbmeta(out)
