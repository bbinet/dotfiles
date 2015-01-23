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

vim +PlugInstall +qall
