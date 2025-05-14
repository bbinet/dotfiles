#!/bin/bash

# sudo apt install pipx virtualenvwrapper

export CWD="$( cd "$( dirname "$0" )" && pwd )"
BACKUP_DIR="${CWD}/dot/tmp/$(date +%Y%m%d_%H%M%S)"

# TODO create new backup dir before replacing dotfiles
for d in $(ls "${CWD}/dot")
do
    if [ "$(realpath ~/.${d})" != "${CWD}/dot/${d}" ]
    then
        mkdir -p $BACKUP_DIR
        mv ~/.${d} $BACKUP_DIR
        ln -sf "${CWD}/dot/${d}" ~/.${d}
    fi
done

if [ "$1" == "-a" ]
then
    sudo apt install pipx virtualenvwrapper
fi

vim +PlugInstall +qall
