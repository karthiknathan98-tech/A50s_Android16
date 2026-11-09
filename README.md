# A50s_Android16

**Android 16 (Baklava)** custom ROM port, offline package generator, and multi-mode flashing toolset tailored specifically for the **Samsung Galaxy A50s** (`SM-A507FN` / `universal9611`).

---

## 📱 Hardware & Target Specifications

| Parameter | Device Specification |
| :--- | :--- |
| **Model** | Samsung Galaxy A50s (`SM-A507FN`, `a50sxx`, `a50s`) |
| **Chipset** | Samsung Exynos 9611 (4x Cortex-A73 @ 2.3GHz + 4x Cortex-A53 @ 1.7GHz) |
| **GPU** | ARM Mali-G72 MP3 |
| **Storage / RAM** | 128 GB UFS 2.1 / 4 GB or 6 GB LPDDR4X |
| **Stock OS Baseline** | Android 11 (One UI 3.1, VNDK 30) |
| **Target OS** | **Android 16 (Release 16, API Level 36, Codename: *Baklava*)** |
| **Target Build ID** | `CP11.251209.009.A1` (`arm64-v8a`) |
| **System Partition** | `/dev/block/sda25` (5.26 GB available) |

---

## 📂 Repository Layout

```
A50s_Android16/
├── README.md                      # Project documentation and specifications
├── a50s_ctl.py                    # Master CLI management tool
├── .gitignore                     # Git rules (excludes heavy ROM binaries >100MB)
├── docs/
│   ├── FLASHING_GUIDE.md          # Comprehensive step-by-step flashing manual
│   ├── PARTITION_MAP.md           # Full UFS partition block device table
│   └── TREBLE_FIXES.md            # Exynos 9611 Android 16 compatibility adjustments
├── installer/
│   └── META-INF/com/google/android/
│       ├── update-binary          # Custom POSIX shell-based TWRP flash installer
│       └── updater-script         # Dummy Edify recovery script
├── scripts/
│   ├── flash_rom.sh               # Automated multi-mode flashing script
│   ├── build_offline_rom.sh       # Offline ROM build and packager script
│   └── make_vbmeta.py             # AVB 2.0 verification-disabled vbmeta generator
└── out/                           # Local build outputs (excluded from git)
    ├── twrp_release/              # Flashable TWRP ZIP package (908 MB)
    ├── odin_release/              # Odin-compatible AP TAR.MD5 package (1.7 GB)
    └── vbmeta_disabled.img        # Patched vbmeta image
```

---

## 🚀 Quick Start

### 1. Check Connected Device Status
Connect your Galaxy A50s via USB or Wireless ADB and run:
```bash
./a50s_ctl.py status
```

### 2. Build or Re-package the Offline ROM
Downloads the Android 16 ARM64 base, patches the AVB vbmeta header, and builds the TWRP ZIP and Odin TAR archives into `out/`:
```bash
./a50s_ctl.py build
```

### 3. Flash the ROM
Launches the interactive multi-mode flasher (detects Recovery, Fastbootd, or Download mode automatically):
```bash
./a50s_ctl.py flash
```

---

## ⚡ Flashing Methods

### Method 1: TWRP Recovery (Recommended)
1. Boot phone into TWRP.
2. Wipe **Dalvik / ART Cache**, **Cache**, and **System**.
3. In TWRP, start **Advanced → ADB Sideload**.
4. Run:
   ```bash
   adb sideload out/twrp_release/Android16_Baklava_A50s_Offline_Flashable.zip
   ```
5. In TWRP, select **Wipe → Format Data** (type `yes`) to decrypt storage.
6. Reboot system.

### Method 2: Fastboot / Fastbootd
1. In TWRP, go to **Reboot → Fastboot** (or `./a50s_ctl.py reboot-fastboot`).
2. Run:
   ```bash
   fastboot flash vbmeta out/vbmeta_disabled.img
   fastboot flash system out/package_root/system.img
   fastboot -w
   fastboot reboot
   ```

### Method 3: Samsung Odin (Download Mode)
1. Boot phone into Download Mode (`./a50s_ctl.py reboot-download` or hold Vol Up + Vol Down while plugging in USB).
2. Load `out/odin_release/AP_A50s_Android16_Offline.tar.md5` into the **AP** slot.
3. Flash via Odin on PC, then immediately boot into recovery to format `/data`.

---

## ⚠️ Important Warning
* Installing custom ROMs requires unlocking the Samsung bootloader, which **permanently trips Knox (`warranty_bit: 0x1`)** and **completely erases all user data**.
* Always back up essential personal files and the `/efs` partition before proceeding.
