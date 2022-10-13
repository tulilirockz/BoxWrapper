local-wrapper
===============

A posix shell script for making binary wrapper scripts
- Can be used with Toolbx, Distrobox, and even Python3 venvs.
- Heavily inspired by [distrobox-export](https://github.com/89luca89/distrobox)
- Tested and used in Bash 5.1.16

## Usage

```
    TOOLBOX_BINARY=distrobox sh localw.sh -b amazing_python_app -s -p "$(which python3)" -t app_container -o "--very-cool-argument"
```
Generates:
```
#!/bin/sh
# toolbox_container python_module root_access
sudo distrobox-enter app_container -- /usr/bin/python3 -m amazing_python_app --very-cool-argument "$@"
```

## Installation

1. Clone this repository
2. Run "install"
3. That's it! It should be installed wherever you specified it!
