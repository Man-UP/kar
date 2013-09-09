#!/bin/bash

set -o errexit
set -o nounset

usage() {
    echo "
    Install dependencies and set up development environment

    Usage:

        arch.sh [-A]

    -A  do not install AUR packages
"
    exit 1
}

should_install_aur_packages=true

while getopts :A opt; do
    case "${opt}" in
        A) should_install_aur_packages=false ;;
        \?|*) usage ;;
    esac
done
unset opt

shift $(( OPTIND - 1 ))

if [[ "${#}" != 0 ]]; then
    usage
fi
unset usage

REPO=$(realpath "$(dirname "$(realpath -- "${BASH_SOURCE[0]}")")/../..")
cd -- "${REPO}"

source scripts/setup/arch-tasks.sh

add_archlinuxfr_repo
install_system_packages

if $should_install_aur_packages; then
    install_aur_packages
fi
unset should_install_aur_packages

create_ve
install_python_packages
install_global_node_packages
install_node_packages

