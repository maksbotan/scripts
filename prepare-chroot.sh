#!/bin/sh

if [ -z "$1" ]; then
    echo "Usage: $0 [dir]"
    exit 1
fi

[ -x "$1"/usr/portage ] || mkdir "$1"/usr/portage
[ -x "$1"/distfiles ] || mkdir "$1"/distfiles
[ -x "$1"/etc/portage ] || mkdir "$1"/etc/portage
[ -x "$1"/root/packs ] || mkdir "$1"/root/packs

mount -t proc none "$1"/proc
mount --bind /dev "$1"/dev
mount --bind /usr/portage "$1"/usr/portage
mount --bind /distfiles "$1"/distfiles

cp /etc/resolv.conf "$1"/etc
cp /etc/portage/mirrors "$1"/etc/portage
