#!/bin/sh
: ${ALPINE_MAKEVM:="https://raw.githubusercontent.com/alpinelinux/alpine-make-vm-image/v0.7.0/alpine-make-vm-image"}
: ${APK_TOOLS_URI:="https://github.com/alpinelinux/apk-tools/releases/download/v2.10.3/apk-tools-2.10.3-x86-linux.tar.gz"}
: ${APK_TOOLS_SHA256:="afe41b98680e69bbf865a32e64dbac929030552bbf65a3397132350ab702da48"}
if [ "$(id -u)" -ne "0" ]; then
	echo "Please run as root"
	exit 1
fi
if ! command -v qemu-img >/dev/null; then
	echo "Please ensure qemu-utils is installed"
	exit 1
fi
export APK_TOOLS_URI
export APK_TOOLS_SHA256
tmp=$(mktemp -u /tmp/alpine.XXXXXX)
wget -qO- "$ALPINE_MAKEVM" | sh /dev/stdin -f qcow2 -c "$tmp" setup.sh \
&& echo Shrinking image, please wait \
&& qemu-img convert -O qcow2 "$tmp" "$1" \
&& [ $SUDO_USER ] && chown "$SUDO_USER": "$1"
rm "$tmp"
