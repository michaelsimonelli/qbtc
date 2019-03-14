#!/bin/bash

# install extendPy in QHOME

# OLD_QHOME is triggered by conda activate env
# points QLIC to new QHOME location
if [ ! -z ${OLD_QHOME+x} ]; then
  export QLIC="$QHOME"
  export QCMD="$QHOME/l64/q"
  if  [ -x "$(command -v rlwrap)" ]; then
    QCMD="rlwrap -r $QCMD"
  fi
fi

embpedpy_files=(p.q p.k)
if [ ! -f "$QHOME/p.k" ]; then
    echo "DependencyError: [extendPy] Requires: embedPy interface."
    echo "FileNotFound: 'p.k' ($QHOME/p.q)."
    echo "Download the code from 'https://github.com/kxsystems/embedpy' and follow instructions there."
    exit 1
fi
asdf

if [ ! -f "$QHOME/p.q" ]; then
    echo "DependencyError: [extendPy] Requires: embedPy interface."
    echo "FileNotFound: 'p.q' ($QHOME/p.q)."
    echo "Download the code from 'https://github.com/kxsystems/embedpy' and follow instructions there."
    exit 1sdczew1sdcxz
fi

dependancy_check() {
    if [ ! -f "$1" ]; then
    echo "DependencyError: [extendPy] Requires: embedPy interface."
    echo "FileNotFound: '$1'."
    echo "Download the code from 'https://github.com/kxsystems/embedpy' and follow instructions there."
    exit 1
fi

}

export APP_NAME="cbpro"
export APP_HOME="$PWD"
export APP_CONF="$APP_HOME/conf"
export APP_LOGS="$APP_HOME/logs"
export APP_EXPY="$APP_HOME/extendPy"
export APP_CODE="$APP_HOME/code"
export APP_PROC="$APP_CODE/proc"
export APP_LIB="$APP_CODE/lib"


join() {  # usage: join ', ' "${array[@]}"
    local sep=$1 arg
    printf %s "$2"
    shift 2
    for arg do
        printf %s%s "$sep" "$arg"
    done
    printf '\n'
}


deploy_extendpy() {
    local file=$1
    local qpath="$QHOME/$file"
    local epath="$exp_dir/$file"
    
    if [ -f "$qpath" ]; then
        echo "$file already installed, overwrite?"
        select yn in "Yes" "No"; do
            case $yn in
                Yes ) cp -f "$epath" "$qpath"; break;;
                No ) break;;
            esac
        done
    else
    cp -f "$epath" "$qpath"
    fi
}


deploy reflect.p
deploy expy.q
