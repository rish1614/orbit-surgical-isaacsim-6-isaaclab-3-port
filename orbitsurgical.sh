#!/usr/bin/env bash

# Copyright (c) 2024, The ORBIT-Surgical Project Developers.
# All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

set -euo pipefail

# Prefer the current uppercase variable; accept the legacy spelling for compatibility.
ISAACLAB_PATH="${ISAACLAB_PATH:-${IsaacLab_PATH:-}}"

if [[ -z "${ISAACLAB_PATH}" ]]; then
    echo "Error: Set ISAACLAB_PATH to your Isaac Lab installation directory." >&2
    exit 1
fi

if [[ ! -x "${ISAACLAB_PATH}/isaaclab.sh" ]]; then
    echo "Error: Cannot find executable ${ISAACLAB_PATH}/isaaclab.sh" >&2
    exit 1
fi

# Always resolve extension paths relative to this script, not the caller's directory.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

"${ISAACLAB_PATH}/isaaclab.sh" -p -m pip install -e source/extensions/orbit.surgical.ext
"${ISAACLAB_PATH}/isaaclab.sh" -p -m pip install -e source/extensions/orbit.surgical.assets
"${ISAACLAB_PATH}/isaaclab.sh" -p -m pip install -e source/extensions/orbit.surgical.tasks
