This is the repo with all my system configurations. It's public just for my comfort, not for public use, but you are free anyways to use everything you want as you need. Just don't blindly install everything on your system without knowing the implications.

Install oneliner (run as root to install system components) (as I just said, don't use):

<pre><!--
--> Url="https://gitlab.com/octospacc/Configs/-/raw/main/RemoteInstall.sh"; <!--
--> if [ -n "$(which curl)" ]; <!--
--> then curl "$Url" | sh; <!--
--> elif [ -n "$(which wget)" ]; <!--
--> then wget -O - "$Url" | sh; <!--
--> else echo "Missing tools. Install \`curl\` or \`wget\`."; <!--
--> fi
</pre>
