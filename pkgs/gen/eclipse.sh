#: Eclipse IDE including Java, Python, C/C++ and git support

# eclipse IDE
$PKG_INSTALL_CMD eclipse
if [ $? -ne 0 ]; then
    err "Failed to install Eclipse IDE"
    exit 1
fi

# Java tools
$PKG_INSTALL_CMD eclipse-jdt
if [ $? -ne 0 ]; then
    err "Failed to install Eclipse JDT"
    exit 1
fi

# Python tools
$PKG_INSTALL_CMD eclipse-pydev
if [ $? -ne 0 ]; then
    err "Failed to install Eclipse PYDEV"
    exit 1
fi

# C/C++ tools
$PKG_INSTALL_CMD eclipse-cdt
if [ $? -ne 0 ]; then
    err "Failed to install Eclipse CDT"
    exit 1
fi

# git
$PKG_INSTALL_CMD eclipse-egit
if [ $? -ne 0 ]; then
    err "Failed to install Eclipse CDT"
    exit 1
fi

exit 1
