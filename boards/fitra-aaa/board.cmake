# Copyright (c) 2024 Nordic Semiconductor ASA
# Copyright (c) 2025 Hitohira.
# SPDX-License-Identifier: Apache-2.0

if(CONFIG_SOC_NRF54L15_CPUAPP)
	board_runner_args(jlink "--device=nRF54L15_M33" "--speed=4000")
	board_runner_args(pyocd "--target=nrf54l")
elseif (CONFIG_SOC_NRF54L15_CPUFLPR)
  board_runner_args(jlink "--device=nRF54L15_RV32")
endif()

if(CONFIG_TFM_FLASH_MERGED_BINARY)
  set_property(TARGET runners_yaml_props_target PROPERTY hex_file tfm_merged.hex)
endif()

# board_set_debugger_ifnset(jlink)
# board_set_flasher_ifnset(jlink)
board_set_debugger_ifnset(pyocd)
board_set_flasher_ifnset(pyocd)

include(${ZEPHYR_BASE}/boards/common/nrfutil.board.cmake)
include(${ZEPHYR_BASE}/boards/common/jlink.board.cmake)
include(${ZEPHYR_BASE}/boards/common/pyocd.board.cmake)
