#!/bin/bash

#
# logging functions
#

log() {
    echo "$(date '+%Y-%m-%dT%H:%M:%S:%s%z')  $*"
}

err() {
    log "ERR  $*" 1>&2
}

info() {
    log "INFO $*"
}

warn() {
    log "WARN $*"
}

dbg() {
    if [ -n "$VM_DEV_SETUP_DBG" ]; then
        # log dbg to stderr so it doesn't upset the function returns
        log "DBG  $*" 1>&2
    fi
}

stats() {
    status=$1
    shift
    info "$# package(s) $status:"
    for pkg in $@
    do
        info "    + $pkg"
    done
}

#
# Validate an environment configuration
#
validateEnv() {
    for envVar in $@
    do
        dbg "validating $envVar = ${!envVar}"
        test -z "${!envVar}" && err "Required envirnoment variable $envVar is missing" && return 1
    done
    return 0
}

#
# Get the system package manager and validate the configuration.
#
getPkgMgr() {
    for pkgMgrEnv in $(find . -name "pkg-mgr-*.env" | sort -u)
    do
        dbg $pkgMgrEnv
        pkgMgr=$(echo "$pkgMgrEnv" | sed 's/.*pkg-mgr-\(.*\)\.env/\1/')
        dbg pkgMgr=$pkgMgr
        if which $pkgMgr &> /dev/null ; then
            echo $pkgMgr
            return
        fi
    done
}

#
# main
#
while [ $# -gt 0 ]
do
    case $1 in
        -n|--non-interactive)
            DEV_SETUP_INTERACTIVE=FALSE
            ;;
    esac
    shift
done

pkgMgr=$(getPkgMgr) && test -z "$pkgMgr" && err "Failed to find a package manager" && exit 1
info "using '$pkgMgr' package manager"
. "pkg-mgr-${pkgMgr}.env"
validateEnv $(cat pkg-mgr-env.req | sed '/^#/d') || exit 1

# update the package manager
$PKG_MGR_UPD_CMD

# upgrade the whole system
$PKG_UPGRADE_CMD

SUCCESS=""
SKIPPED=""
FAILED=""

# install packages    
for pkg in $(find ./pkgs -name "*.sh" | sort -u)
do
    pkgName=$(echo "$pkg" | sed 's/.*\/\(.*\)\.sh/\1/')
    ans=y
    if [ "$DEV_SETUP_INTERACTIVE" != "FALSE" ]; then
        echo -n "Do you want to install $pkgName? [Y/n]: "
        read ans
    fi
    case $ans in
        [yY]*)
            info "installing $pkgName"
            /bin/bash $pkg
            if [ $? -eq 0 ]; then
                dbg "$pkgName SUCCEEDED"
                SUCCESS="$SUCCESS $pkgName"
                dbg $SUCCESS
            else
                dbg "$pkgName FAILED"
                FAILED="$FAILED $pkgName"
            fi
            ;;
        *)
            info "skipping $pkgName"
            SKIPPED="$SKIPPED $pkgName"
            ;;
    esac
done

stats succeeded $SUCCESS
stats skipped $SKIPPED
stats failed $FAILED
