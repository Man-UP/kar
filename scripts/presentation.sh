#!/bin/bash

set -o errexit
set -o nounset

mode=1024x768
do_start=true

while getopts r opt; do
    case "${opt}" in
	r) do_start=false ;;
    esac
done


start() {
    read -p "Plug in projector"
    xrandr  --output LVDS1 --mode "${mode}" \
            --output VGA1 --mode  "${mode}" --same-as LVDS1 

}

reset(){
    xrandr --output LVDS1 --auto \
	   --output VGA1 --off

}

if $do_start; then
    start
else
    reset
fi
unset do_start