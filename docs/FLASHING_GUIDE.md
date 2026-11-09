# Android 16 (Baklava) Offline Custom ROM Guide for Samsung Galaxy A50s

- **Target Device**: Samsung Galaxy A50s (`SM-A507FN`, `a50s`, `a50sxx`)
- **Chipset**: Samsung Exynos 9611 (`universal9611`)
- **OS Version**: Android 16 (Release 16, API Level 36, Codename: *Baklava*)
- **Build ID**: `CP11.251209.009.A1`
- **Security Patch**: 2026-01-05
- **Architecture**: `arm64-v8a` (64-bit)

---

## 📦 Package Inventory & Directory Structure

All offline build artifacts are located in:
`/Users/karthik/.gemini/antigravity/scratch/a50s_android16_rom/`

| File / Folder | Size | Description |
| :--- | :--- | :--- |
| `twrp_release/Android16_Baklava_A50s_Offline_Flashable.zip` | **908 MB** | Complete flashable ZIP package for TWRP, OrangeFox, or `adb sideload`. |
| `odin_release/AP_A50s_Android16_Offline.tar.md5` | **1.7 GB** | Odin-compatible TAR package for flashing via Samsung Odin or Heimdall. |
| `package_root/system.img` | **1.7 GB** | Raw Android 16 system image ready for fastbootd. |
| `package_root/vbmeta.img` | **4.0 KB** | Patched AVB 2.0 vbmeta image (`--flags 2`) to disable dm-verity and verified boot enforcement. |
| `flash_rom.sh` | **2.5 KB** | Automated helper script to detect device state and execute flashing. |

---

## ⚠️ Phase 1: Bootloader Unlocking (Wipes Data & Trips Knox)

Samsung Knox locks bootloader signature verification by default. Unlocking it is required to boot custom partitions.

> [!WARNING]
> Unlocking the bootloader will **permanently trip the Knox e-fuse** from `0x0` to `0x1` and will **completely wipe all personal data**. Back up your data before continuing.

1. On your phone, go to **Settings → About phone → Software information**. Tap **Build number** 7 times to enable Developer options.
2. Go to **Settings → Developer options**.
3. Toggle **OEM unlocking** to **ON** and toggle **USB debugging** to **ON**.
4. Power off your phone completely.
5. While holding **Volume Up + Volume Down**, plug the phone into your computer via a **physical USB-C cable**.
6. The green "Warning" screen will appear. **Long press Volume Up** to enter "Device Unlock Mode".
7. Press **Volume Up** once to confirm unlock. The phone will format `/data` and reboot.

---

## 📲 Phase 2: Installing Custom Recovery (TWRP)

1. Download TWRP recovery for `a50sxx` (`SM-A507FN`).
2. Power off phone, hold **Volume Up + Volume Down**, plug in USB to enter Download Mode (press Volume Up once to proceed).
3. On PC, open Odin:
   - Place `twrp-a50s.tar` in the **AP** slot.
   - In Options, **untick Auto Reboot**.
   - Click **Start**.
4. Once flashed, unplug cable and force reboot into TWRP by holding **Volume Down + Power**, and the second the screen goes black, immediately switch to holding **Volume Up + Power** until the TWRP splash screen appears.

---

## ⚡ Phase 3: Flashing Android 16

### Option A: Via TWRP (Recommended)
1. In TWRP, go to **Wipe → Advanced Wipe** → select **Dalvik / ART Cache, Cache, System**. Swipe to Wipe.
2. Connect phone via USB.
3. Run the automated script from your Mac terminal:
   ```bash
   /Users/karthik/.gemini/antigravity/scratch/a50s_android16_rom/flash_rom.sh
   ```
   *Select Option 1 to push and flash, or Option 2 for `adb sideload`.*
4. Or manually in TWRP:
   - Go to **Advanced → ADB Sideload** → swipe to start.
   - On Mac, run:
     ```bash
     adb sideload /Users/karthik/.gemini/antigravity/scratch/a50s_android16_rom/twrp_release/Android16_Baklava_A50s_Offline_Flashable.zip
     ```
5. Once complete, go to **Wipe → Format Data** (type `yes`) to decrypt storage.
6. Reboot System!

---

### Option B: Via Fastboot / Fastbootd
If you are in TWRP or Fastbootd:
```bash
# 1. Reboot to fastbootd
adb reboot fastboot

# 2. Flash disabled vbmeta to prevent bootloop
fastboot flash vbmeta /Users/karthik/.gemini/antigravity/scratch/a50s_android16_rom/package_root/vbmeta.img

# 3. Flash Android 16 system image
fastboot flash system /Users/karthik/.gemini/antigravity/scratch/a50s_android16_rom/package_root/system.img

# 4. Wipe user data and reboot
fastboot -w
fastboot reboot
```

---

### Option C: Via Samsung Odin (Download Mode)
1. Boot phone into **Download Mode**.
2. In Odin, load:
   - **AP**: `/Users/karthik/.gemini/antigravity/scratch/a50s_android16_rom/odin_release/AP_A50s_Android16_Offline.tar.md5`
3. Click **Start**.
4. Once Odin says `PASS`, immediately boot to recovery and format `/data`.

---

## 🛠️ Post-Installation & Treble Fixes

Because the Galaxy A50s uses Samsung's Exynos 9611 Android 11 vendor partition:
1. **Brightness Curve**: In Phh Treble Settings (under System Settings), enable **Alternative backlight scale** if the slider appears inverted.
2. **Audio / In-Call Volume**: Enable **Disable audio effects** or **Use alternate audio policy** if call audio routing defaults to loudspeaker.
3. **Mali Graphics**: Android 16 automatically uses the device's native Vulkan 1.1 / OpenGL ES 3.2 drivers provided by the vendor partition.
