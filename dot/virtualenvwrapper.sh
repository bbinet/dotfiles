# protect from modified PATH that may contain virtualenv bin path
if [ -f /usr/local/bin/virtualenvwrapper.sh ]; then
    export PATH=${PATH/$PREPEND_PATH:/}
    source /usr/local/bin/virtualenvwrapper.sh
    export PATH=$PREPEND_PATH:$PATH
fi
