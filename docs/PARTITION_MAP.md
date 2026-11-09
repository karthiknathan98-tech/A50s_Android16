# Samsung Galaxy A50s (SM-A507FN) Partition Map

- **Platform**: `universal9611` (Exynos 9611 Octa-core)
- **Storage**: 128 GB UFS 2.1
- **Architecture**: A-only system-as-root (SAR), non-A/B

| Partition Name | Block Device | Size | Mount Point | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **boot** | `/dev/block/sda14` | 55.0 MB | None | Linux 4.14 Kernel + Ramdisk |
| **recovery** | `/dev/block/sda15` | 64.5 MB | None | Stock Recovery or TWRP Recovery |
| **radio** | `/dev/block/sda16` | 50.0 MB | None | Shannon337 Cellular Modem Firmware |
| **vbmeta** | `/dev/block/sda23` | 64.0 KB | None | Android Verified Boot 2.0 metadata |
| **system** | `/dev/block/sda25` | 5,260 MB | `/` (SAR) | Android System OS image (Android 16 GSI fits here) |
| **vendor** | `/dev/block/sda26` | 840.0 MB | `/vendor` | Samsung Exynos 9611 proprietary HALs & drivers |
| **product** | `/dev/block/sda27` | 240.0 MB | `/product` | Product specific apps, overlays, fonts |
| **cache** | `/dev/block/sda28` | 400.0 MB | `/cache` | Recovery command cache and temporary files |
| **efs** | `/dev/block/sda3` | 20.0 MB | `/efs` | IMEI, calibration data, and baseband NVRAM |
| **userdata** | `/dev/block/sda32` | 114,868 MB | `/data` | User applications, internal storage, encrypted data |

### Flashing Safety Note:
Never format, overwrite, or zero `/dev/block/sda3` (`efs`) or `/dev/block/sda7` (`sec_efs`). Loss of these partitions permanently damages the IMEI and cellular connectivity.
