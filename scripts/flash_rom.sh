#!/usr/bin/env bash
# Automated Flasher & Helper for Samsung Galaxy A50s (SM-A507FN / universal9611)
# Android 16 (Baklava) Offline ROM

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TWRP_ZIP="$SCRIPT_DIR/twrp_release/Android16_Baklava_A50s_Offline_Flashable.zip"
ODIN_TAR="$SCRIPT_DIR/odin_release/AP_A50s_Android16_Offline.tar.md5"
SYSTEM_IMG="$SCRIPT_DIR/package_root/system.img"
VBMETA_IMG="$SCRIPT_DIR/package_root/vbmeta.img"

echo "======================================================="
echo "   Samsung Galaxy A50s - Android 16 (Baklava) Flasher   "
echo "======================================================="
echo ""

echo "Available Offline ROM Packages:"
echo " 1. TWRP Flashable ZIP : $TWRP_ZIP ($(ls -lh "$TWRP_ZIP" | awk '{print $5}'))"
echo " 2. Odin TAR.MD5       : $ODIN_TAR ($(ls -lh "$ODIN_TAR" | awk '{print $5}'))"
echo " 3. Raw Images         : system.img ($(ls -lh "$SYSTEM_IMG" | awk '{print $5}')), vbmeta.img"
echo ""

echo "Detecting connected device..."
ADB_DEVICE=$(adb devices | awk 'NR>1 && $2=="device" {print $1; exit}' || true)
RECOVERY_DEVICE=$(adb devices | awk 'NR>1 && $2=="recovery" {print $1; exit}' || true)
SIDELOAD_DEVICE=$(adb devices | awk 'NR>1 && $2=="sideload" {print $1; exit}' || true)
FASTBOOT_DEVICE=$(fastboot devices 2>/dev/null | awk '{print $1; exit}' || true)

if [ -n "$RECOVERY_DEVICE" ]; then
    echo "[+] Detected device in TWRP Recovery mode ($RECOVERY_DEVICE)!"
    echo "Choose installation method:"
    echo "  1) Push and flash ZIP directly to device"
    echo "  2) Sideload ZIP via ADB"
    read -rp "Enter choice [1-2]: " choice
    if [ "$choice" = "1" ]; then
        echo "[*] Pushing Android 16 ZIP to /sdcard/..."
        adb -s "$RECOVERY_DEVICE" push "$TWRP_ZIP" /sdcard/a16_a50s.zip
        echo "[*] Installing via TWRP openrecoveryscript..."
        adb -s "$RECOVERY_DEVICE" shell "twrp install /sdcard/a16_a50s.zip"
        echo "[✓] Flashing triggered in TWRP!"
    else
        echo "[*] Starting ADB Sideload..."
        adb -s "$RECOVERY_DEVICE" sideload "$TWRP_ZIP"
        echo "[✓] Sideload finished!"
    fi
    exit 0
fi

if [ -n "$SIDELOAD_DEVICE" ]; then
    echo "[+] Detected device in ADB Sideload mode ($SIDELOAD_DEVICE)!"
    echo "[*] Sending $TWRP_ZIP via adb sideload..."
    adb -s "$SIDELOAD_DEVICE" sideload "$TWRP_ZIP"
    echo "[✓] Sideload complete!"
    exit 0
fi

if [ -n "$FASTBOOT_DEVICE" ]; then
    echo "[+] Detected device in Fastboot/Fastbootd mode ($FASTBOOT_DEVICE)!"
    echo "[*] Flashing vbmeta (AVB verification disabled)..."
    fastboot flash vbmeta "$VBMETA_IMG"
    echo "[*] Flashing Android 16 System image..."
    fastboot flash system "$SYSTEM_IMG"
    echo "[*] Erasing cache and userdata..."
    fastboot erase cache
    fastboot -w || true
    echo "[✓] Fastboot flash complete! Rebooting..."
    fastboot reboot
    exit 0
fi

if [ -n "$ADB_DEVICE" ]; then
    echo "[+] Detected device in standard Android mode ($ADB_DEVICE)."
    echo "What would you like to do?"
    echo "  1) Reboot into Recovery (TWRP)"
    echo "  2) Reboot into Fastboot / Fastbootd"
    echo "  3) Reboot into Download Mode (for Odin / Heimdall)"
    read -rp "Enter choice [1-3]: " choice
    case "$choice" in
        1) adb -s "$ADB_DEVICE" reboot recovery ;;
        2) adb -s "$ADB_DEVICE" reboot fastboot ;;
        3) adb -s "$ADB_DEVICE" reboot download ;;
        *) echo "Invalid choice." ;;
    esac
    exit 0
fi

echo "[!] No device detected in ADB, Recovery, or Fastboot mode."
echo "Please connect your phone via physical USB cable and ensure:"
echo " - USB Debugging is ON (for ADB)"
echo " - Or phone is booted into TWRP Recovery (Hold Vol Up + Power with USB plugged in)"
echo " - Or phone is in Download Mode (Hold Vol Up + Vol Down while plugging in USB)"
