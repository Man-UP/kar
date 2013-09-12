# =============================================================================
# = Configuration                                                             =
# =============================================================================

REPO=$(readlink -f "$(dirname "$(readlink -f -- "${BASH_SOURCE[0]}")")/../..")

NODE_GLOBAL_PACKAGES=(
    'meteorite'
)

SYSTEM_PACKAGES=(
    'curl'
    'git'
    'google-chrome'
    'mongodb-server'
    'wmctrl'
    'xdotool'
)


# =============================================================================
# = Tasks                                                                     =
# =============================================================================

install_global_node_packages() {
    sudo npm install --global "${NODE_GLOBAL_PACKAGES[@]}"
}

install_meteor() {
    curl https://install.meteor.com | sh
}

install_node() {
    sudo apt-get update
    sudo apt-get --assume-yes install python-software-properties python g++ make
    sudo add-apt-repository --yes ppa:chris-lea/node.js
    sudo apt-get update
    sudo apt-get --assume-yes install nodejs
}

install_system_packages() {
    sudo apt-get --assume-yes install "${SYSTEM_PACKAGES[@]}"
}
