#!/usr/bin/env python3
"""
a50s_ctl.py - Control & Flashing Management Utility for Samsung Galaxy A50s
Supports Android 16 (Baklava) Offline ROM flashing and hardware diagnostics.
"""

from __future__ import annotations

import os
import sys
import subprocess
from pathlib import Path
from typing import Optional, List

REPO_ROOT = Path(__file__).resolve().parent

def run_cmd(cmd: list[str], check: bool = True) -> str:
    res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if check and res.returncode != 0:
        raise RuntimeError(f"Command failed ({res.returncode}): {' '.join(cmd)}\n{res.stderr}")
    return res.stdout.strip()

def get_adb_device() -> str | None:
    out = run_cmd(["adb", "devices", "-l"], check=False)
    for line in out.splitlines()[1:]:
        parts = line.strip().split()
        if len(parts) >= 2 and parts[1] == "device":
            return parts[0]
    return None

def check_status():
    print("=" * 60)
    print("      Samsung Galaxy A50s (SM-A507FN) Hardware Status       ")
    print("=" * 60)
    dev = get_adb_device()
    if not dev:
        print("[!] No ADB device found online via USB or Wireless ADB.")
        print("    If device is in Download mode or Recovery, run `a50s_ctl.py flash`.")
        return

    print(f"[+] Device Transport ID: {dev}")
    props = {
        "Model": "ro.product.model",
        "Hardware": "ro.hardware",
        "SoC Chipset": "ro.chipname",
        "Platform": "ro.board.platform",
        "Android Version": "ro.build.version.release",
        "One UI / SEP": "ro.build.version.sep",
        "Knox Warranty Bit": "ro.boot.warranty_bit",
        "OEM Unlock Allowed": "sys.oem_unlock_allowed",
    }
    for label, prop in props.items():
        val = run_cmd(["adb", "-s", dev, "shell", "getprop", prop], check=False)
        print(f"  - {label:<22}: {val}")

def reboot_device(mode: str):
    dev = get_adb_device()
    if not dev:
        print("[!] No device detected in normal Android mode.")
        return
    print(f"[*] Rebooting {dev} to {mode} mode...")
    run_cmd(["adb", "-s", dev, "reboot", mode], check=False)
    print(f"[✓] Reboot to {mode} triggered.")

def flash_rom():
    flasher = REPO_ROOT / "scripts" / "flash_rom.sh"
    if not flasher.exists():
        print(f"[ERROR] Flasher script not found at {flasher}")
        return
    os.execv("/bin/bash", ["bash", str(flasher)])

def build_rom():
    builder = REPO_ROOT / "scripts" / "build_offline_rom.sh"
    if not builder.exists():
        print(f"[ERROR] Builder script not found at {builder}")
        return
    os.execv("/bin/bash", ["bash", str(builder)])

def print_help():
    print("""
Usage: ./a50s_ctl.py <command>

Commands:
  status             Show connected device specs, Knox state, and platform props
  flash              Launch the interactive Android 16 flasher
  build              Rebuild offline TWRP zip and Odin TAR packages from source
  reboot-recovery    Reboot connected phone into TWRP/Stock Recovery
  reboot-fastboot    Reboot connected phone into Fastbootd
  reboot-download    Reboot connected phone into Samsung Download (Odin) mode
""")

if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] in ("-h", "--help", "help"):
        print_help()
        sys.exit(0)

    cmd = sys.argv[1].lower()
    if cmd == "status":
        check_status()
    elif cmd == "flash":
        flash_rom()
    elif cmd == "build":
        build_rom()
    elif cmd == "reboot-recovery":
        reboot_device("recovery")
    elif cmd == "reboot-fastboot":
        reboot_device("fastboot")
    elif cmd == "reboot-download":
        reboot_device("download")
    else:
        print(f"Unknown command: {cmd}")
        print_help()
        sys.exit(1)
