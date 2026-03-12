# SlimeVR Tracker nRF — Workspace Guidelines

## Build and Flash

**SDK:** nRF Connect SDK (NCS) v3.2.3 — all builds use `west`.

```bash
# Build for a specific board (pristine)
west build -p always -b <board>

# Common targets
west build -p always -b xiao_nrf54l15/nrf54l15/cpuapp
west build -p always -b xiao_ble/nrf52840
west build -p always -b nrf52840dongle/nrf52840

# Flash
west flash
```

`build.sh` wraps the xiao_nrf54l15 build with MISE environment activation; output goes to `build_out.log`.

## Architecture

**Stack:** Zephyr RTOS + NCS — pure C (C11/GNU). No C++.

| Layer | Where |
|---|---|
| Entry point | `src/main.c` — reset detection, DFU, pairing, delegates to `system_init()` + `sensor_setup()` |
| Sensor drivers | `src/sensor/imu/` (BMI270, ICM42688/45686, LSM6DS*) + `src/sensor/mag/` |
| Sensor abstraction | `src/sensor/interface.h` — `sensor_imu_t` / `sensor_mag_t` function-pointer structs |
| Auto-detection | `src/sensor/scan.c` / `scan_spi.c` — probes I2C addresses + whoami registers at boot |
| Fusion backends | `src/sensor/fusion/` — selectable: VQF (`vqf-c/`), XioFusion (`Fusion/`), MotionSense, none |
| Wireless | `src/connection/` — ESB (Enhanced ShockBurst) protocol |
| System | `src/system/` — battery, LED, power management |
| Config | `src/config.h` — NVS-backed bitfield settings with `CONFIG_0_SETTINGS_READ()` macros |
| Retained state | `src/retained.h` — SRAM region preserved across resets (calib, reboot counter) |

Source is compiled via `GLOB_RECURSE src/*.c` in the top-level `CMakeLists.txt` — there is **no** `src/CMakeLists.txt`.

## Board / SoC Layer Cake

DTS overlays are applied in order:

1. `socs/<soc>.overlay` — retained RAM, SRAM sizing, DFU SRAM alias
2. `boards/<vendor>/<board>/board.overlay` — pinctrl, I2C/SPI buses, battery ADC, LEDs, dock pins
3. `boards/<board_target>.overlay` (top-level) — includes the SoC overlay, optional XIAO-specific pin adjustments

Board-specific Kconfig layering: `prj.conf` (base) → `boards/<target>.conf` (per-board overrides).

## Key Conventions

- **Board-conditional logic** lives in `src/globals.h` using `#ifdef CONFIG_BOARD_*` for quaternion corrections and magnetometer axis remapping. Don't scatter board logic elsewhere.
- **Sensor whoami IDs** are catalogued in `src/sensor/sensors_enum.h` — check here before adding a new driver to avoid duplicates.
- **License headers:** SlimeVR-authored files carry MIT/Apache-2.0 dual-license. Nordic-originated files use `LicenseRef-Nordic-5-Clause`. Match the surrounding file.
- **Partition maps:** Every UF2 bootloader target has a corresponding `pm_static_<board>.yml`; add one when introducing a new UF2 board.
- **`sample.yaml`** `platform_allow` list must be updated when adding a new officially supported target.

## Adding a New IMU/Mag Driver

1. Add source file to `src/sensor/imu/` (or `mag/`).
2. Implement `sensor_imu_t` (or `sensor_mag_t`) interface from `src/sensor/interface.h`.
3. Register whoami in `src/sensor/sensors_enum.h`.
4. Add detection entry in `src/sensor/scan.c` / `scan_spi.c`.
5. No CMakeLists edits needed — build picks up all `src/*.c` automatically.

## Adding a New Board

1. Create `boards/<vendor>/<board>/` with `board.yaml`, `<board>.dts`, `<board>_defconfig`, `Kconfig.board`, `Kconfig.defconfig`.
2. Add top-level `boards/<target>.overlay` (include the appropriate `socs/` overlay).
3. Add top-level `boards/<target>.conf` (layer on top of `prj.conf`).
4. Add `pm_static_<target>.yml` if the board uses a UF2 bootloader.
5. Update `sample.yaml` `platform_allow`.
