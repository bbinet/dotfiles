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
    wget -O /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py
    sudo python2 /tmp/get-pip.py --upgrade --force-reinstall
    sudo python3 /tmp/get-pip.py --upgrade --force-reinstall
    echo "Installing/upgrading virtualenvwrapper..."
    pip2 install --upgrade --user virtualenvwrapper
    pip3 install --upgrade --user virtualenvwrapper
    echo "Installing pipenv..."
    pip2 install --upgrade --user pipenv
    pip3 install --upgrade --user pipenv
    if [ ! -f ~/.bin/hub ]
    then
        echo "Installing hub..."
       curl -L https://github.com/github/hub/releases/download/v2.12.1/hub-linux-amd64-2.12.1.tgz | tar zx --strip=2 -C ~/.bin/ hub-linux-amd64-2.12.1/bin/hub
    fi
fi

vim +PlugInstall +qall
