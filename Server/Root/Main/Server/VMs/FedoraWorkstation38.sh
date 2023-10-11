#!/bin/sh
cd "$( dirname "$( realpath "$0" )" )"
while true; do

qemu-system-x86_64 \
	-accel kvm \
	-cpu host \
	-smp 3 \
	-m 1400M \
	-hda ./FedoraWorkstation38.qcow2 \
	-device e1000,netdev=net0 \
	-netdev user,id=net0,hostfwd=tcp::33893-:3389,hostfwd=udp::33893-:3389 \
	-spice port=5953,password=tux.FedoraWorkstation38 \
;
#	-cdrom /Main/Transfers/Storage/Fedora-Workstation-Live-x86_64-38-1.6.iso \
#	-vnc :10 \
#	-display none \

sleep 500
done
