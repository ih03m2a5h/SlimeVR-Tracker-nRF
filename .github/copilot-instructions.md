# SlimeVR-Tracker-nRF AI Coding Instructions

This project is a firmware for SlimeVR Trackers based on Nordic nRF52/nRF54 Series SoCs, built using the Zephyr RTOS and nRF Connect SDK (NCS).

## Project Architecture & Data Flow
- **Main Entry (`src/main.c`)**: Handles system initialization, power-on/off logic, and button events.
- **Sensor Layer (`src/sensor/`)**: 
    - `sensor.c`: Orchestrates IMU data acquisition and fusion.
    - `fusion/`: Contains various sensor fusion algorithms (Mahony, Madgwick, VQF).
    - `imu/`, `mag/`: Driver-specific implementations for various sensors.
- **Connection Layer (`src/connection/`)**:
    - `esb.c`: Implements the Enhanced ShockBurst (ESB) protocol for low-latency communication with SlimeVR servers.
    - `connection.c`: Manages the connection state and data packet assembly.
- **System Layer (`src/system/`)**: Handles battery tracking, LED patterns, and hardware-specific system tasks.

## Key Development Patterns
- **Zephyr RTOS First**: Always prefer Zephyr/NCS APIs over bare-metal or custom implementations.
    - Use `K_THREAD_DEFINE` for background tasks.
    - Use `LOG_*` macros for debugging (configured in `prj.conf`).
    - Use `DT_*` macros to access hardware defined in DeviceTree.
- **Hardware Abstraction**: Hardware differences are managed via DeviceTree overlays (`boards/*.overlay`) and Kconfig (`prj.conf`, `boards/*.conf`).
- **Sensor Alignment**: IMU orientation and axis mapping are defined in `src/globals.h` using `SENSOR_QUATERNION_CORRECTION` and `SENSOR_MAGNETOMETER_AXES_ALIGNMENT`.
- **Persistent Settings**: Use the Zephyr `Settings` subsystem for storing calibration and configuration data.

## Critical Workflows
- **Building**: Use `west` with `sysbuild` enabled.
    ```bash
    west build -b <board_target> --sysbuild
    ```
    Example targets: `xiao_ble/nrf52840`, `nrf52840dongle/nrf52840`.
- **Flashing**: `west flash` (requires a programmer like J-Link) or use UF2 bootloader if supported.
- **Debugging**: Monitor logs via RTT (Segger Real Time Transfer). Ensure `CONFIG_USE_SEGGER_RTT=y` is set.

## Important Files
- `prj.conf`: Global Kconfig configuration.
- `src/globals.h`: Global constants and sensor alignment macros.
- `west.yml`: External dependencies (NCS version, etc.).
- `pm_static_*.yml`: Static partition layouts for the Partition Manager.
