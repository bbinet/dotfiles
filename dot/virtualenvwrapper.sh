# protect from modified PATH that may contain virtualenv bin path
if [ -f ~/.local/bin/virtualenvwrapper.sh ]; then
    export PATH=${PATH/$PREPEND_PATH:/}
    source ~/.local/bin/virtualenvwrapper.sh
    export PATH=$PREPEND_PATH:$PATH
fi
