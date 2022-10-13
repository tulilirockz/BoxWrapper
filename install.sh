#!/usr/bin/env bash

install ./localw "${INSTALL_DIR:-"$HOME/.local/bin"}" && echo "Local-wrapper was installed successfully in ${INSTALL_DIR:-"$HOME/.local/bin"}"
