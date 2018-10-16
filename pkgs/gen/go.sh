echo "TODO"

alias gob='for dir in $(find . -name "*.go" -exec dirname "{}" \; | sort -u) ; do echo "dir = $dir" ; cd $dir ; go build . || echo -e "***\nFAILED TO BUILD $dir\n***\n"; cd - ; done'

exit 1
