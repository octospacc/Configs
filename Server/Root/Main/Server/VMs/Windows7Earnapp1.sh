#!/bin/sh
cd "$( dirname "$( realpath "$0" )" )"
while true; do

qemu-system-x86_64 \
	-accel kvm \
	-cpu host \
	-smp 1 \
	-m 256M \
	-hda ./Windows7Earnapp1.qcow2 \
	-display none \
;
#	-cdrom ./Windows7Custom2.iso \
#	-vnc :10 \
#	-display none \

sleep 500
done
