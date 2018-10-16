#:Docker Community Edition is a container development and management platform.

dockerVer=$(docker -v)

if [ -n "$dockerVer" ]; then
    echo "$dockerVer is already installed. Do you want to re-install it? [y/N]: "
    read ans
    ans=$(lower $ans)
    if [ "$ans" != "y" ]; then
        exit 0
    fi
fi

$PKG_INSTALL_CMD apt-transport-https ca-certificates curl software-properties-common
if [ $? -ne 0 ]; then
    err "Failed to install packages needed for docker install"
    exit 1
fi

# install Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
echo "TODO"
exit 1
