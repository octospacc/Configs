#!/bin/sh

ScopePath=""
SetScope(){
    [ "$1" = "Root" ] && ScopePath="/"
    [ "$1" = "Home" ] && ScopePath="${HOME}/"
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
	do
		CpItem "$p"
	done
}

CpSub(){
	LBase="$1"; shift
	RBase="$1"; shift
	for s in $@
	do
		CpItems ${LBase}${s}${RBase}
	done
}

CpSufx(){
	Base="$1"; shift
	CpSub "$Base" "" $@
}

cpfile(){
    echo "$1"
    rm -rf "./$1" && \
    mkdir -p "./$1" && \
    rm -rf "./$1" && \
	cp --no-target-directory "${ScopePath}$1" "./$1"
}

cpdir(){
	echo "$1"
	mkdir -p "./$1" && \
	cp --recursive --no-target-directory "${ScopePath}$1" "./$1"
}
