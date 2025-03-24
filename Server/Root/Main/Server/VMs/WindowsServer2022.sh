#!/bin/sh
cd "$( dirname "$( realpath "$0" )" )"
while true; do

#qemu-system-x86_64 \
/opt/usr/bin/qemu-system-x86_64 \
	-accel kvm \
	-bios /usr/share/qemu/OVMF.fd \
	-smbios type=0,version=UX305UA.201 \
	-smbios type=1,manufacturer=ASUS,product=UX305UA,version=2021.1 \
	-smbios "type=2,manufacturer=Intel,version=2021.5,product=Intel i9-12900K" \
	-smbios type=3,manufacturer=XBZJ \
	-smbios type=17,manufacturer=KINGSTON,loc_pfx=DDR5,speed=4800,serial=000000,part=0000 \
	-smbios type=4,manufacturer=Intel,max-speed=4800,current-speed=4800 \
	-cpu "host,family=6,model=158,stepping=2,model_id=Intel(R) Core(TM) i9-12900K CPU @ 2.60GHz,vmware-cpuid-freq=false,enforce=false,host-phys-bits=true,hypervisor=off" \
	-machine q35,kernel_irqchip=on \
	-smp 4 \
	-m 3700M \
	-drive file=./WindowsServer2022.qcow2,format=qcow2,index=0,media=disk \
	-device e1000,netdev=net0 \
	-netdev user,id=net0,hostfwd=tcp::3389-:3389,hostfwd=udp::3389-:3389 \
	-display none \
;
#	-device intel-hda \
#	-device hda-duplex \
#	-audiodev driver=none,id=none \
#	-cdrom ./SERVER_EVAL_x64FRE_en-us.iso \
#	-hda ./WindowsServer2022.qcow2 \
#	-drive file=./WindowsServer2022.qcow2,format=qcow2,if=none,id=NVME1 \
#	-device nvme,drive=NVME1,serial=nvme-1 \
#	-vnc :10 \
#	-display none \

sleep 500
done
