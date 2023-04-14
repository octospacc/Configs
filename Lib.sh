#!/bin/sh

mkcd(){
	mkdir -vp "$1" && \
	cd "$1"
}

cpdir(){
	echo "'$1'"
	mkdir -p "$1" && \
	cp -rT "/$1" "./$1"
}
