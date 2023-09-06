#!/bin/sh

ScopePath=""
SetScope(){
	if [ "$1" = "Root" ]
	then ScopePath="/"
	elif [ "$1" = "Home" ]
	then ScopePath="${HOME}/"
	#else ScopePath="$1/"
	fi
}

mkcd(){
	mkdir -vp "./$1" && \
	cd "$1"
}

CpItem(){
	[ -f "${ScopePath}$1" ] && cpfile "$1"
	[ -d "${ScopePath}$1" ] && cpdir "$1"
}

CpItems(){
	for p in $@
	do CpItem "$p"
	done
}

CpSub(){
	LBase="$1"; shift
	RBase="$1"; shift
	for s in $@
	do
		PathBack="${PWD}"
		cd "${ScopePath}"
		# Here will happen any wildcard expansion
		for i in ${LBase}${s}${RBase}
		do
			cd "${PathBack}"
			CpItem "${i}"
		done
	done
}

CpSufx(){
	Base="$1"; shift
	CpSub "$Base" "" $@
}

cpfile(){
	if [ -f "${ScopePath}$1" ]
	then
		echo "$1"
		rm -rf "./$1" && \
		mkdir -p "./$1" && \
		rm -rf "./$1" && \
		cp --no-target-directory "${ScopePath}$1" "./$1"
	fi
}

cpdir(){
	echo "$1"
	mkdir -p "./$1" && \
	cp --recursive --no-target-directory "${ScopePath}$1" "./$1"
}
