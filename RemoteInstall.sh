#!/bin/sh

[ -z "$(which git)" ] \
	&& echo "Missing tools. Install \`git\`." \
	&& exit 1

[ "$(whoami)" = "root" ] \
	&& echo "Running as root; copying system files."

[ "$(whoami)" != "root" ] \
	&& echo "Running as user; only copying home files."

true \
&& git clone --depth 1 "https://gitlab.com/octospacc/Configs" \
&& cd ./Configs \
&& echo "Which install target?" \
&& echo "(Available: $(ls -d */))" \
&& read Target \
&& sh ./Install.sh "$Target"
