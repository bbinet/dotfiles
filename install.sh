#!/bin/bash

export CWD="$( cd "$( dirname "$0" )" && pwd )"

for d in $(ls "${CWD}/dot")
do
    rm -f ~/.${d}
    ln -sf "${CWD}/dot/${d}" ~/.${d}
done

if [ "$1" == "-a" ]
then
    (dpkg -l | grep -q python-pip) && sudo apt purge python-pip
    which pip && sudo pip install --upgrade pip || sudo python get-pip.py
    if [ ! -f ~/.local/bin/virtualenvwrapper.sh ]
    then
        echo "Installing virtualenvwrapper..."
        pip install --user virtualenvwrapper
    fi
    if [ ! -f ~/.local/bin/pipenv ]
    then
        echo "Installing pipenv..."
        pip install --user pipenv
    fi
    if [ ! -f ~/.local/bin/pepper ]
    then
        echo "Installing salt-pepper..."
        pip install --user salt-pepper
    fi
    if [ ! -f ~/.bin/hub ]
    then
       echo "fixme download hub"
       #curl -L https://github.com/github/hub/releases/download/v2.2.1/hub-linux-amd64-2.2.1.tar.gz | tar zx --strip=1 -C ~/.bin/ hub-linux-amd64-2.2.1/hub
    fi
fi

vim +PlugInstall +qall
