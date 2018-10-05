# dev-setup
A configurable tool for setting up the development environment on Linux [Virtual] Machines

# Installing and Running
This program is a BASH application that runs in your BASH shell; therefore, there are potentially numerous ways to run it. Two of the most usful are presented below. By default the app runs in `interactive` mode in which is prompts the user to install or skip each of the packages in the `pkgs` subdirectory. If you want to run in non-interactive mode --where the app simply installs every package automatically-- then pass the `-n` or `--non-interactive` flag or set an environment variable `export DEV_SETUP_INTERACTIVE=FALSE` (this is especially useful in the curl case below).

## Clone, hack and use
If you want to customize the setup by adding packages or "adjusting" the script in some way, or if you just want to run the app locally, you can clone the repo change into the top-level directory and run the app.

`git clone <repo> && cd <repo> && ./dev-setup.sh`

## Using curl
You can run the app directly from the github repo using curl:

`curl https://github.com/cthain/dev-setup/raw/master/dev-setup.sh | /bin/bash`

By default the app will run in interactive mode because it will use only the 

# Package managers
## Supported package managers
The current version supports the following package managers:
* `apt`
* `yum`

## Adding a package manager
TODO

# Install scripts
## Adding an install script
