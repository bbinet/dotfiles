#!/bin/bash

export CWD="$( cd "$( dirname "$0" )" && pwd )"

for d in $(ls "${CWD}/dot")
do
    rm -f ~/.${d}
    ln -sf "${CWD}/dot/${d}" ~/.${d}
done

if [ ! -f ~/.pip_bootstrap_profile.sh ]
then
    ./pip/bootstrap_pip2014.sh
fi

if [ ! -d ~/.virtualenvs/syntax-checkers ]
then
    source ~/.pip_bootstrap_profile.sh
    mkvirtualenv syntax-checkers
    pip install -r pip/syntax-checkers.txt
    deactivate
fi

if [ "$1" == "-a" ]
then
    if [ ! -f ~/.bin/hub ]
    then
       curl -L https://github.com/github/hub/releases/download/v2.2.1/hub-linux-amd64-2.2.1.tar.gz | tar zx --strip=1 -C ~/.bin/ hub-linux-amd64-2.2.1/hub
    fi
fi

vim +PlugInstall +qall
