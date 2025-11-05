#!/usr/bin/env bash
set -euo pipefail

updates=$(ssh root@homeassistant.local ha addons --raw-json | jq '.data.addons | map(select(.update_available == true )) | .[] .slug')
if [[ -n $updates ]]
then
    for update in $updates
    do
        ssh root@homeassistant.local ha addons update "$update"
    done
fi
ssh root@homeassistant.local ha core update || true
ssh root@homeassistant.local ha os update || true

ssh pi3.local 'sudo apt-get update && sudo apt-get dist-upgrade -y && if [[ -e /var/run/reboot-required ]]; then sudo reboot; fi'
