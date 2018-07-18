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
        echo "Installing hub..."
       curl -L https://github.com/github/hub/releases/download/v2.5.0/hub-linux-amd64-2.5.0.tgz | tar zx --strip=2 -C ~/.bin/ hub-linux-amd64-2.5.0/bin/hub
    fi
fi

vim +PlugInstall +qall
