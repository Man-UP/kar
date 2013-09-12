#!/bin/bash

set -o errexit
set -o nounset

usage() {
    echo "
    Build kar

    Usage:

        build.sh
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

repo=$(readlink -f "$(dirname "$(readlink -f -- "${BASH_SOURCE[0]}")")/..")
bundle=${repo}/bundle.tar.gz

cd -- "${repo}"
rm -fr "${bundle}" bundle
./scripts/meteor.sh bundle "${bundle}"
tar --extract --file "${bundle}"
cd bundle/programs/server/node_modules
rm -fr fibers
npm install fibers

