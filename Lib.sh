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
