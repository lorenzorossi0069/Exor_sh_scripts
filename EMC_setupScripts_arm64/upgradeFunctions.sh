#!/bin/sh

function movefileTo {
	local destPath=$1
	local fileName=$2

	if [[ ! -e $SETUPDIR/$fileName ]] ; then
		echo "file $SETUPDIR/$fileName not found"
		exit 1
	else
		cp $SETUPDIR/$fileName $destPath
	fi
	#echo "DBG: f() added $destPath/$fileName"; echo "press enter to continue"; read dummy
}




#--------------------------------------
function createUnexistingFolder {
        local newFolder=$1
        if [[ ! -d $newFolder ]] ; then
                echo "creating $newFolder"
                mkdir $newFolder
        else
                echo "folder already found: $newFolder"
        fi
}



#--------------------------------------
function updateFileAndCheck {
	local destPath=$1
	local fileName=$2
	local isOk="";
	#rename old copy for safety
echo "mv $destPath/$fileName   $destPath/${fileName}_OLD_WITHOUT_AW"
	mv $destPath/$fileName   $destPath/${fileName}_OLD_WITHOUT_AW
	cp $SETUPDIR/$fileName   $destPath/$fileName

	echo "check differences in updated file $destPath/$fileName"
	echo
	echo "begin diff"
	diff $destPath/$fileName   $destPath/$fileName_OLD_WITHOUT_AW
	echo "end diff"
	echo

	echo -n "enter y if $fileName is ok " ; read isOk
	if [[ $isOk != y ]] ; then
		echo "Check manually differences of $destPath/$fileName"
                echo "======================="
                echo "PROGRAM NOT COMPLETED!!!"
                echo "======================="
		exit 1
	fi
}
