#!/bin/bash

set -o errexit
set -o nounset

usage() {
    echo "
    Install dependencies and set up development environment

    Usage:

        ubuntu.sh
"
    exit 1
}

while getopts : opt; do
    case "${opt}" in
        \?|*) usage ;;
    esac
done
unset opt

shift $(( OPTIND - 1 ))

if [[ "${#}" != 0 ]]; then
    usage
fi
unset usage

REPO=$(readlink -f "$(dirname "$(readlink -f -- "${BASH_SOURCE[0]}")")/../..")
cd -- "${REPO}"

source scripts/setup/ubuntu-tasks.sh

install_system_packages

install_node
install_global_node_packages
install_meteor
