#!/bin/bash

set -o errexit
set -o nounset

do_start=true
mode=1024x768
repo=$(readlink -f "$(dirname "$(readlink -f -- "${BASH_SOURCE[0]}")")/..")

while getopts r opt; do
    case "${opt}" in
        r) do_start=false ;;
    esac
done

start() {
    # Ensure it's not already running
    sudo killall node &> /dev/null || true
    killall chrome &> /dev/null || true

    # Sanity check for projector
    read -p "Plug in projector then press RETURN "

    # Setup displays
    xrandr  --output LVDS1 --mode "${mode}" \
            --output VGA1  --mode "${mode}" --same-as LVDS1

    cd -- "${repo}"

    # Launch kar
    root_url="http://$(hostname)/"

    sudo PORT=80 \
         "ROOT_URL=${root_url}" \
         MONGO_URL=mongodb://localhost:27017/kar \
         node \
         bundle/main.js &

    # Wait for it to start serving
    until netstat -tln | tr -s ' ' | cut -d ' ' -f 4 | grep -q ':80$'; do
        sleep 0.1
    done

    # Lanunch a viewer
    google-chrome --incognito \
                  --kiosk \
                  --user-data=/tmp \
                  "${root_url}view" &

    # Wait for the viewer window, then fullscreen it.
    until wmctrl -a 'Google Chrome'; do
        sleep 0.1
    done

    xdotool key alt+shift+space \
            key alt+space \
            key alt+space \
            key alt+ctrl+x
}

reset() {
    xrandr --output LVDS1 --auto \
           --output VGA1  --off
}

if $do_start; then
    start
else
    reset
fi
unset do_start

