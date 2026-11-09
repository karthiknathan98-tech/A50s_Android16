#!/usr/bin/env bash
# build_offline_rom.sh
# Downloads and packages Android 16 (Baklava) for Samsung Galaxy A50s (Exynos 9611)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$REPO_ROOT/out/build_tmp"
OUT_DIR="$REPO_ROOT/out"

GSI_URL="https://dl.google.com/developers/android/baklava/images/gsi/aosp_arm64-exp-CP11.251209.009.A1-14840729-59a822d9.zip"
ZIP_NAME="a16_gsi_arm64.zip"

echo "=================================================="
echo "   Building Android 16 Offline ROM for A50s       "
echo "=================================================="

mkdir -p "$BUILD_DIR"
mkdir -p "$OUT_DIR/twrp_release"
mkdir -p "$OUT_DIR/odin_release"

# 1. Download official Android 16 ARM64 image if not cached
if [ ! -f "$OUT_DIR/$ZIP_NAME" ]; then
    echo "[*] Downloading official Android 16 GSI from Google..."
    curl -L -C - -o "$OUT_DIR/$ZIP_NAME" "$GSI_URL"
else
    echo "[✓] Using cached Android 16 GSI: $OUT_DIR/$ZIP_NAME"
fi

# 2. Extract system.img
echo "[*] Extracting system.img..."
unzip -o "$OUT_DIR/$ZIP_NAME" system.img -d "$BUILD_DIR"

# 3. Generate disabled vbmeta
echo "[*] Generating disabled vbmeta..."
python3 "$SCRIPT_DIR/make_vbmeta.py" "$BUILD_DIR/vbmeta.img"
cp "$BUILD_DIR/vbmeta.img" "$OUT_DIR/vbmeta_disabled.img"

# 4. Copy META-INF installer
echo "[*] Packaging TWRP Flashable ZIP..."
cp -r "$REPO_ROOT/installer/META-INF" "$BUILD_DIR/"

cd "$BUILD_DIR"
zip -r -1 "$OUT_DIR/twrp_release/Android16_Baklava_A50s_Offline_Flashable.zip" META-INF system.img vbmeta.img
echo "[✓] TWRP ZIP built: $OUT_DIR/twrp_release/Android16_Baklava_A50s_Offline_Flashable.zip"

# 5. Build Odin TAR package
echo "[*] Packaging Odin TAR.MD5..."
tar -cf "$OUT_DIR/odin_release/AP_A50s_Android16_Offline.tar" system.img vbmeta.img
cd "$OUT_DIR/odin_release"
cp AP_A50s_Android16_Offline.tar AP_A50s_Android16_Offline.tar.md5
md5 -q AP_A50s_Android16_Offline.tar >> AP_A50s_Android16_Offline.tar.md5
rm AP_A50s_Android16_Offline.tar
echo "[✓] Odin TAR.MD5 built: $OUT_DIR/odin_release/AP_A50s_Android16_Offline.tar.md5"

# Clean temporary files
rm -rf "$BUILD_DIR"

echo ""
echo "=================================================="
echo "   Build Complete! Artifacts ready in out/        "
echo "=================================================="
