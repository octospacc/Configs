#!/bin/sh
cd "$( dirname "$( realpath "$0" )" )"

CopyCfg() {
	for Type in "" "."
	do
		[ "$(whoami)" = "root" ] && [ -d "$1/Root" ] && \
			cp -r $(find "$1/Root" -maxdepth 1 -mindepth 1 -name "${Type}*") /
		[ "$(whoami)" != "root" ] && [ -d "$1/Home" ] && \
			cp -r $(find "$1/Home" -maxdepth 1 -mindepth 1 -name "${Type}*") ~/
        # TODO: && cat all *.part.{head,tail} files into their respective one
	done
}

Cur="$1"
while [ -n "$Cur" ]
do
	if [ -d "$Cur" ]
	then
		echo "$Cur"
		CopyCfg "$Cur"
	fi
	shift > /dev/null 2>&1 || Cur=""
	Cur="$1"
done
