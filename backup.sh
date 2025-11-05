#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

just comet download-homeassistant-backup > homeassistantbackup.tar.gz

