# Suppress "unique_unit_address_if_enabled" to handle some overlaps
list(APPEND EXTRA_DTC_FLAGS "-Wno-unique_unit_address_if_enabled")

# Drop the board's default application overlay if it was also passed through
# EXTRA_DTC_OVERLAY_FILE. Zephyr auto-discovers this file from boards/ already.
set(default_board_overlay "${APPLICATION_SOURCE_DIR}/boards/fitra-aaa_nrf54l15_cpuapp.overlay")
if(EXISTS "${default_board_overlay}" AND EXTRA_DTC_OVERLAY_FILE)
	file(REAL_PATH "${default_board_overlay}" default_board_overlay_real BASE_DIRECTORY "${APPLICATION_SOURCE_DIR}")
	string(REPLACE " " ";" extra_dtc_overlay_files "${EXTRA_DTC_OVERLAY_FILE}")
	set(filtered_extra_dtc_overlay_files)

	foreach(extra_dtc_overlay_file IN LISTS extra_dtc_overlay_files)
		if(extra_dtc_overlay_file STREQUAL "")
			continue()
		endif()

		file(REAL_PATH "${extra_dtc_overlay_file}" extra_dtc_overlay_file_real BASE_DIRECTORY "${APPLICATION_SOURCE_DIR}")
		if(NOT extra_dtc_overlay_file_real STREQUAL default_board_overlay_real)
			list(APPEND filtered_extra_dtc_overlay_files "${extra_dtc_overlay_file}")
		endif()
	endforeach()

	set(EXTRA_DTC_OVERLAY_FILE "${filtered_extra_dtc_overlay_files}")
endif()
