# How to Build for XIAO nRF54L15

This document describes how to build the SlimeVR-Tracker-nRF firmware for the `xiao_nrf54l15` board (specifically the `nrf54l15/cpuapp` target) using the nRF Connect SDK (NCS) on Ubuntu 25.10.

## 1. Prerequisites
- **nRF Connect SDK (NCS):** Version v3.2.3 (or later compatible)
- **Toolchain:** NCS embedded toolchain (which contains Zephyr SDK, Python, and `west`).
- Ubuntu 25.10 Environment

## 2. Setting up the Toolchain using `mise` (rtx)
Since adding NCS toolchains directly to your global `$PATH` might conflict with system Python or other development tools, setting the environment per-project is ideal.
The user is utilizing [`mise` (formerly `rtx`)](https://mise.jdx.dev/). You can configure `.mise.toml` inside the root directory to transparently inject the `ncs` toolchain values just like `direnv`:

```toml
[env]
# NCS Zephyr directory base
ZEPHYR_BASE = "{{env.HOME}}/ncs/v3.2.3/zephyr"

# NCS Zephyr compiler SDK. Replace `927563c840` with your actual Toolchain hash in `~/ncs/toolchains/`
ZEPHYR_SDK_INSTALL_DIR = "{{env.HOME}}/ncs/toolchains/927563c840/opt/zephyr-sdk"
ZEPHYR_TOOLCHAIN_VARIANT = "zephyr"

# Make "west" available automatically in this directory
_.path = "{{env.HOME}}/ncs/toolchains/927563c840/usr/local/bin"

# Linker library paths required by NCS's Python (`libpython3.12.so.1.0` not found error)
LD_LIBRARY_PATH = "{{env.HOME}}/ncs/toolchains/927563c840/usr/local/lib:{{env.HOME}}/ncs/toolchains/927563c840/usr/lib:$LD_LIBRARY_PATH"

# Prevents mise's system python injection from missing the `west` module.
MISE_DISABLE_TOOLS = "python"
```
After saving the file, run `mise trust` in the root directory to activate it natively.

## 3. Build the Firmware
Once the project environment applies the `mise.toml` configurations, you can build the firmware using west:

```bash
west build -p always -b xiao_nrf54l15/nrf54l15/cpuapp
```

- `-p always` guarantees a pristine build state preventing CMake caching issues.
- `-b xiao_nrf54l15/nrf54l15/cpuapp` ensures we are targeting the `nrf54l15` application core of the board.

If successful, `west` will print the compilation steps ending with a flash/RAM usage metric and `.hex` firmware generation in `build/zephyr/merged.hex`.

## 4. Resolved Code Fixes
When compiling against Zephyr v3.2.3 APIs, a C compiler syntax error was identified in `src/connection/connection.c` involving `buf` dereferencing and redefinition (an integer assignment directly to a `uint16_t *` without dereferencing `*buf`). This has been patched manually in the build test to prevent fatal `ninja: build stopped: subcommand failed.` failures.
