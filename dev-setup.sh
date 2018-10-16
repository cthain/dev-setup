#!/bin/bash

# Copyright 2018 Chris Thain
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
    if [ -n "$DBG" ]; then
        # log dbg to stderr so it doesn't upset the function returns
        log "DBG  $*" 1>&2
    fi
}

##
# Indicates if the given string is in the array
#
inArray() {
    needle=$1
    shift
    for haystack in $@
    do
        test "$needle" == "$haystack" && return 0
    done
    return 1
}

lower() {
    echo $@ | tr [:upper:] [:lower:]
}

upper() {
    echo $@ | tr [:lower:] [:upper:]
}

##
# Log install stats
#
stats() {
    status=$1
    shift
    info "$# package(s) $status:"
    for pkg in $@
    do
        info "    + $pkg"
    done
}

##
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

##
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

##
# Get the list of packages to install. Look in the gen folder and the specific pkg mgr folder and favour the pkg mgr folder.
#
getPkgs() {
    genPkgs=$(find ./pkgs/gen -name "*.sh" | sort -u)
    pkgs=""
    for genPkg in $genPkgs
    do
        dbg "found gen package $genPkg"
        genPkgName=$(basename $genPkg)
        if [ -f "./pkgs/$pkgMgr/$genPkgName" ]; then
            dbg "found $pkgMgr package for $genPkgName, using it instead of the gen package"
            pkgs="$pkgs ./pkgs/$pkgMgr/$genPkgName"
        else
            dbg "using gen package"
            pkgs="$pkgs $genPkg"
        fi
    done
    echo $pkgs
}

##
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

SUCCESS=""
SKIPPED=""
FAILED=""

# install packages    
for pkg in $(getPkgs)
do
    pkgName=$(echo "$pkg" | sed 's/.*\/\(.*\)\.sh/\1/')
    ans=y
    if [ "$DEV_SETUP_INTERACTIVE" != "FALSE" ]; then
        echo ""
        grep '^#:' $pkg | sed 's/^#:\(.*\)/\1/'
        echo ""
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
