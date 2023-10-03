#!/bin/sh
cd "$( dirname "$( realpath "$0" )" )"
while true; do

qemu-system-x86_64 \
	-accel kvm \
	-cpu host \
	-smp 2 \
	-m 700M \
	-hda ./Lubuntu2022NonProxied.qcow2 \
	-device e1000,netdev=net0 \
	-netdev user,id=net0,hostfwd=tcp::33891-:3389,hostfwd=udp::33891-:3389,hostfwd=tcp::50991-:5900,hostfwd=udp::50991-:5900 \
	-vnc :10 \
;
#	-cdrom ./lubuntu-22.04.2-desktop-amd64.iso \
#	-netdev user,id=net0,hostfwd=tcp::33891-:3389,hostfwd=udp::33891-:3389 \
#	-vnc :10 \
#	-display none \

sleep 500
done
