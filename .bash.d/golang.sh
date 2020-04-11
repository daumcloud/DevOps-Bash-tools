#!/usr/bin/env bash
# shellcheck disable=SC2230
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: circa 2015 (forked from .bashrc)
#
#  https://github.com/harisekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

# ============================================================================ #
#                                  G o l a n g
# ============================================================================ #
# Golang

bash_tools="${bash_tools:-$(dirname "${BASH_SOURCE[0]}")/..}"

github="${github:-$HOME/github}"

# shellcheck disable=SC1090
#. "$bash_tools/.bash.d/os_detection.sh"

export GOPATH="$github/go-tools"
alias gopath='cd "$GOPATH"'
alias gogo='gopath'
alias cdgo='gopath'
alias gosrc='cd "$GOPATH/src"'
alias gobin='cd "$GOPATH/bin"'

if [ -d ~/go/bin ]; then
    add_PATH ~/go/bin
fi

# manual installation of 1.5 mismatches with HomeBrew 1.6 installed to $PATH and
#export GOROOT="/usr/local/go"
# causes:
# imports runtime/internal/sys: cannot find package "runtime/internal/sys" in any of:
# /usr/local/go/src/runtime/internal/sys (from $GOROOT)
# /Users/hari/github/go-tools/src/runtime/internal/sys (from $GOPATH)
if type -P go &>/dev/null; then
    if isMac; then
        GOROOT="$(dirname "$(dirname "$(greadlink -f "$(type -P go)")")")"
    else
        GOROOT="$(dirname "$(dirname "$(readlink -f "$(type -P go)")")")"
    fi
    export GOROOT
    add_PATH "$GOROOT/bin"
    add_PATH "$GOROOT/libexec/bin"
    add_PATH "$GOPATH/bin"
fi

if type -P colorgo &>/dev/null; then
    alias go=colorgo
fi

alias lsgobin='ls -d ~/go/bin/* "$GOROOT"/{bin,libexec/bin}/* "$GOPATH/bin/"* 2>/dev/null'
alias llgobin='ls -ld ~/go/bin/* "$GOROOT"/{bin,libexec/bin}/* "$GOPATH/bin/"* 2>/dev/null'
