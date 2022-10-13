#!/usr/bin/env bash

# Copyright 2022 tulilirockz.pub@gmail.com
#
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

has() { command -v "$1" &> /dev/null ;}
add_tag() { TAGS="$* $TAGS" ;}
push_back() { COMMAND="$* $COMMAND" ;}
push_front() { COMMAND="$COMMAND $*" ;}
error() { echo -e "$*" >&2 ;}
blocking_error() { error "$*" ; exit 1 ;}
TAGS=""
COMMAND=""
PYTHON_VENV=""
BINARY_NAME=""
TOOLBOX_CONTAINER=""
SUDO_ACCESS=""
EXPORT_LOCATION=""
EXTRA_OPTIONS=""

while :; do
    case "$1" in
        -p|--python-venv)
            if [ -n "$2" ] ; then
                PYTHON_VENV="$2"
                add_tag "python_module"
                shift
                shift
            fi
            ;;
        -t|--toolbox|-d|--distrobox)
            if [ -n "$2" ] ; then
                TOOLBOX_CONTAINER="$2"
                add_tag "toolbox_container"
                shift
                shift
            fi
            ;;
        -b|--bin)
            if [ -n "$2" ] ; then
                BINARY_NAME="$2"
                shift
                shift
            fi
            ;;
        -s|--sudo|-r|-root)
            SUDO_ACCESS="1"
            add_tag "root_access"
            shift
            ;;
        -e|--export|--export-location)
            if [ -n "$2" ] ; then
                EXPORT_LOCATION="$2"
                shift
                shift
            fi
            ;;
        -o|--options|--extra-options)
            if [ -n "$2" ] ; then
                EXTRA_OPTIONS="$2"
                shift
                shift
            fi
            ;;
        -*)
            blocking_error "Unknown option $1"
            ;;
        *)
            break
            ;;
    esac
done
if [ -n "$BASH_VERSION" ]; then
    set posix
fi
set -o errexit nounset

COMMAND="${BINARY_NAME?"Error: Binary name was not defined, specify it with \"-b\" "}"

if [ -n "$PYTHON_VENV" ] ; then
    [ ! -s "$PYTHON_VENV" ] && error "Python3 interpreter not found: $PYTHON_VENV"
    push_back "$PYTHON_VENV" -m
fi

if [ -n "${TOOLBOX_CONTAINER}" ] ; then
    if ! has "${CONTAINER_BACKEND-/usr/bin/podman}" ; then
        error "Container backend could not be found: ${CONTAINER_BACKEND-podman}"
    elif ! "${CONTAINER_BACKEND:-/usr/bin/podman}" container exists "${TOOLBOX_CONTAINER}" ; then
        error "Container does not exist: ${TOOLBOX_CONTAINER}"
    fi
    if ! has "${TOOLBOX_BINARY:-/usr/bin/toolbox}" ; then
        error "Toolbox binary not found in path"
    fi
    if [ "${TOOLBOX_BINARY}" = "distrobox" ] ; then
        push_back "distrobox-enter" "${TOOLBOX_CONTAINER}" "--"
    else
        push_back "${TOOLBOX_BINARY:-/usr/bin/toolbox}" -c "${TOOLBOX_CONTAINER}"
    fi
fi

[ -d "$EXPORT_LOCATION" ] && EXPORT_LOCATION="${EXPORT_LOCATION}/${BINARY_NAME##.*}"
[ -n "$SUDO_ACCESS" ] && push_back "${SUDO_PROGRAM-sudo}"

generate_output() {
    cat << EOF
#!/bin/sh
# ${TAGS}
${COMMAND} ${EXTRA_OPTIONS} "\$@"
EOF
    return $?
}

if [ -n "$EXPORT_LOCATION" ] ; then
    touch "$EXPORT_LOCATION"
    chmod +x "$EXPORT_LOCATION"
    generate_output | tee "$EXPORT_LOCATION"
else
    generate_output
fi
