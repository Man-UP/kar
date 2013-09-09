# =============================================================================
# = Configuration                                                             =
# =============================================================================

REPO=$(realpath "$(dirname "$(realpath -- "${BASH_SOURCE[0]}")")/../..")

ENV=$REPO/env

NODE_GLOBAL_PACKAGES=(
    'meteorite'
)

PYTHON_PACKAGES=( )

PYTHON_VERSION=2.7

SYSTEM_PACKAGES=(
    'curl'
    'git'
    'nodejs'
    'yaourt'
)


# =============================================================================
# = Tasks                                                                     =
# =============================================================================

add_archlinuxfr_repo() {
    if ! grep -q '\[archlinuxfr\]' /etc/pacman.conf; then
        sudo tee -a /etc/pacman.conf <<EOF
[archlinuxfr]
SigLevel = Never
Server = http://repo.archlinux.fr/\$arch
EOF
    fi
}

create_ve() {
    "virtualenv-$PYTHON_VERSION" "$ENV"
}

install_global_node_packages() {
    sudo npm install --global "${NODE_GLOBAL_PACKAGES[@]}"
}

install_meteor() {
    curl https://install.meteor.com | sh
}

install_system_packages() {
    sudo pacman --needed --noconfirm --refresh --sync "${SYSTEM_PACKAGES[@]}"
}

