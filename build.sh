#!/bin/bash
PROJECT_ROOT="$(cd "$(dirname "$0")"; pwd)"
echo "Starting west build via MISE..." > build_out.log
eval "$(MISE_DISABLE_TOOLS=python MISE_YES=1 mise env 2>/dev/null)"
west build -p always -b an54lq-15/nrf54l15/cpuapp -- -DBOARD_ROOT="${PROJECT_ROOT}" >> build_out.log 2>&1
echo "Exit code: $?" >> build_out.log
echo "DONE" >> build_out.log
