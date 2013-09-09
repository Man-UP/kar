#!/bin/bash

set -o errexit
set -o nounset

REPO=$(readlink -f "$(dirname "$(readlink -f -- "${BASH_SOURCE[0]}")")/..")
cd -- "${REPO}/kar"

mrt "${@}"

