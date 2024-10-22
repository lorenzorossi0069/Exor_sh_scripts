#!/bin/sh

function createLinkToPath {
	if [[ -e $1 ]] ; then
	  ln -s $1 .
	  echo "created link to $1"
	else
	  echo "$1 not found"
	  exit 1
	fi
}

createLinkToPath '../lib_AW/wl'
#createLinkToPath '../lib_AW/libWl.sh'
#createLinkToPath '../lib_AW/cmd_executeSequence.sh'