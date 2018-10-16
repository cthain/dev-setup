#:git is an industry standard distributed software configuration management tool.
$PKG_INSTALL_CMD git
exit $?

git config --global user.email cthain@mdacorporation.com
git config --global user.name "Chris Thain"
git config --global credential.helper "cache --timeout=28800"
