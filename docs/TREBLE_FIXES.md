# Exynos 9611 Treble Compatibility Fixes for Android 16

When running AOSP Android 16 on Samsung's Android 11 vendor partition (`VNDK 30`), apply the following adjustments via **Phh Treble Settings** (found in Settings → System) or via `setprop`:

---

### 1. Display & Backlight Curve
On Samsung AMOLED panels, the default Android 16 linear brightness curve may cause screen flickering or inverted slider behavior.
* **Fix**: Navigate to **Settings → System → Treble Settings → Samsung Features**.
* Enable: **Alternative backlight scale**
* Or run via ADB / root shell:
  ```bash
  setprop persist.sys.phh.backlight54 1
  ```

---

### 2. Audio & In-Call Volume
Samsung routes voice calls and media audio through proprietary HAL interfaces (`libaudiohal`).
* **Fix**: Navigate to **Settings → System → Treble Settings → Audio**.
* Enable: **Disable audio effects**
* Enable: **Use alternate audio policy**
* Or run via ADB:
  ```bash
  setprop persist.sys.phh.disable_audio_effects 1
  ```

---

### 3. Navigation Bar / Gestures
By default, AOSP enables the gesture pill navigation bar. If you prefer the 3-button layout:
* Navigate to **Settings → System → Gestures → System navigation**.
* Toggle between **Gesture navigation** and **3-button navigation**.

---

### 4. Camera (HAL3 Symbols)
If third-party camera apps crash on initial launch:
* Install **Open Camera** or **GCam Go** (which support Camera2 legacy HALs without requiring Knox-dependent post-processing extensions).
