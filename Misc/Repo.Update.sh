#!/bin/sh
cd "$( dirname "$( realpath "$0" )" )"
. ../Lib.sh

SetScope Home
mkcd ./Home
    cpdir .dotfiles
    cpfile .tmux.conf
    cpfile .config/micro/settings.json
