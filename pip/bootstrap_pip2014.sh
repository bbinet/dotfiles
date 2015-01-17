#!/bin/bash
cd "$(mktemp -d -t pip.setup.XXXXXXX)";

SCRIPTNAME="${0}";

function inapp () {
    if [[ "${SCRIPTNAME}" == *".app/"* ]]; then
        return 0;
    else
        return 1;
    fi;
}

if inapp; then
    # Detect the user's existing environment.
    source ~/.bash_profile;
fi;

export PREVIOUS_PATH="${PATH}";

echo '
pip_bootstrap_runtime () {
    if [[ -z "${BOOTSTRAP_PYTHON}" ]]; then
        export BOOTSTRAP_PYTHON="/usr/bin/python";
    fi;

    if [[ -z "${PYTHON_USER_BIN}" ]]; then
        # Set up environment.

        # Note that you can’t just "import site", because distribute installs a
        # site.py without the __main__ block.

        export PYTHON_USER_BIN="$(${BOOTSTRAP_PYTHON} -c '\''import site; site._script()'\'' --user-base)/bin";
        export PYTHON_USER_LIB="$(${BOOTSTRAP_PYTHON} -c '\''import site; site._script()'\'' --user-site)";

        export PATH="${PYTHON_USER_BIN}:${PATH}";

        if [[ "$(uname)" == "Darwin" ]]; then
            export STANDARD_CACHE_DIR="${HOME}/Library/Caches/org.pip-installer.pip";
        else
            export STANDARD_CACHE_DIR="${XDG_CACHE_HOME:-${HOME}/.cache}/pip";
        fi;

        export WHEELHOUSE="${STANDARD_CACHE_DIR}/Wheelhouse";

        # Configure pip to always do the thing it should do out of the box, and not
        # re-download packages every time I sneeze.
        export PIP_USE_WHEEL="yes";
        export PIP_DOWNLOAD_CACHE="${STANDARD_CACHE_DIR}/Downloads";
        export PIP_FIND_LINKS="file://${WHEELHOUSE}";
        export PIP_WHEEL_DIR="${WHEELHOUSE}";

    fi;

    # Set up shell-local stuff unconditionally.
    if [[ -e "${PYTHON_USER_BIN}/virtualenvwrapper.sh" ]]; then
        source "${PYTHON_USER_BIN}/virtualenvwrapper.sh";
    fi;

    function pip () {

        # When you run "pip install" in your regular shell outside a
        # virtualenv, it should just work, meaning, install stuff into your
        # home directory.  But, let’s not affect the operation of pip within
        # virtualenvs or as executed by any tools (such as tox or virtualenv
        # itself) which need to run it via automation and not via a shell.

        if [[ -z "${VIRTUAL_ENV:-}" ]]; then
            env PIP_USER=yes pip "$@";
        else
            command pip "$@";
        fi;
    }
}

pip_bootstrap_runtime;

' > "${HOME}/.pip_bootstrap_profile.sh";

if [[ "$(uname)" == Darwin ]]; then
    export STANDARD_LOG_DIR="Library/Logs";
else
    export STANDARD_LOG_DIR=".cache/pip";
fi;

mkdir -p "${HOME}/${STANDARD_LOG_DIR}";

BOOTSTRAP_LOG="${STANDARD_LOG_DIR}/pip-bootstrap.log";

echo "Install log available in '~/${BOOTSTRAP_LOG}'.";
echo "Installing ... ";

download () {
    curl -sO "$@";
}

message () {
    echo "$@";
    echo "$@" >&10;
}

progress () {
    if inapp; then
        message "PROGRESS:${1}";
    fi;
}

(
    set -x;
    set -e;

    progress "1";

    source "${HOME}/.pip_bootstrap_profile.sh";

    progress "5";

    # Just for this subshell.
    export PIP_USER=yes;
    export PIP_UPGRADE=yes;

    export PIP_BUILD="$(mktemp -d -t pip.build.XXXXXX)";
    echo "Build directory: ${PIP_BUILD}";
    message "Downloading pip.";
    download https://bootstrap.pypa.io/get-pip.py;
    progress "20";
    message "Installing pip.";
    "${BOOTSTRAP_PYTHON}" get-pip.py;
    progress "30";
    message "Preparing to upgrade setuptools.";
    # Make sure that if your user site is enabled, you get _recent_ setuptools,
    # without which virtualenvwrapper et. al. will just be horribly broken.
    mkdir -p "${PYTHON_USER_LIB}";
    mkdir -p "${PYTHON_USER_BIN}";
    echo 'import sys; sys.path.insert(0, sitedir)' > \
         "${PYTHON_USER_LIB}/pip-bootstrap.pth";
    message "Upgrading setuptools.";
    pip install setuptools;
    progress "40";
    message "Installing wheel.";
    pip install wheel;
    progress "50";
    message "Building wheels...";
    progress "55";
    message "Building wheel for setuptools.";
    pip wheel setuptools;
    progress "60";
    message "Building wheel for virtualenv.";
    pip wheel virtualenv;
    progress "70";
    message "Installing virtualenv and virtualenvwrapper...";
    pip install virtualenv virtualenvwrapper;
    progress "90";
    message "Configuring virtualenvwrapper...";
    source "$(type -p virtualenvwrapper.sh)";
    virtualenvwrapper_initialize;
    progress "100";

) 10>&1 > "${HOME}/${BOOTSTRAP_LOG}" 2>&1;

STATUS="$?";

if [[ "${STATUS}" == "0" ]]; then
    echo "Done. Please enjoy Pip!";
else
    cat "${HOME}/${BOOTSTRAP_LOG}";
    echo;
    echo "Sorry. It looks like something went wrong; see above to figure out what.";
    exit "${STATUS}";
fi;

echo "Success, pip is set up for ${USER}"'!';
