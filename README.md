local-wrapper
===============

A posix shell script for making binary wrapper scripts
- Can be used with Toolbx, Distrobox, and even Python3 venvs.
- Heavily inspired by [distrobox-export](https://github.com/89luca89/distrobox)
- Tested and used in Bash 5.1.16

## Usage
Run localw with whatever options you need (check them out with -h):
```
    CONTAINER_MANAGER=distrobox ./localw -b amazing_python_app -e ~/.local/bin -r -p "$(which python3)" -c app_container -o "--very-cool-argument"
```
Then it'll generate:
```
#!/bin/sh
# toolbox_container python_module root_access
sudo distrobox-enter app_container -- /usr/bin/python3 -m amazing_python_app --very-cool-argument "$@"
```

## Installation

1. Clone this repository
2. Make the script executable with chmod or something like that
3. Copy the script to a folder in your PATH
4. That's it!
