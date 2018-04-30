#!/bin/bash
#set -x

Args="${@}"

if [ "$#" -ne 1 ]
then
  echo "Usage: delete_dir_terraform.sh Dir"
  exit 1
fi

# Mac OS
if man wc | grep BSD &>/dev/null
then
    wc_command()      { gwc -l; }
fi

# GNU date (Linux)
if man wc | grep GNU &>/dev/null
then
    wc_command()      { wc -l; }
fi

backend_is () { 
	cat "${1}/terraform.tfstate" | jq ". | .backend.type,.backend.config.key"
	read -p "[Yes OR No , Are you sure to remove ?] --> [  ${1} ]  " -n 1 -r
	echo    # (optional) move to a new line
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
    		# do dangerous stuff
		echo "remove ${1} ..."
		rm -rf ${1}
	fi
}
export -f backend_is

get_count_and_size () {
ListFile=`find ${1} -type d -name '.terraform' -print`
export COUNTER=`find ${1} -type d -name '.terraform' -print | wc_command`
if [ ! "$COUNTER" -ge "1" ]; then echo "NO directory .terraform"; exit; fi
export SIZE=`du -sch ${ListFile} | tail -1 | cut -f 1`
}

get_count_and_size ${Args}

read -p "[You can save ${SIZE} if we delete ${COUNTER} '.terraform' present in ${Args} do you proceed  ?] --> [ yes / no ] " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	read -p "[Enter in interactive mode ?] --> [ Yes / Answer No will remove all '.terraform' with no confirmation ] " -n 1 -r
	echo    # (optional) move to a new line
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
	find ${Args} -type d -name '.terraform' -exec bash -c 'backend_is "{}"' \; 
	else
	find ${Args} -type d -name '.terraform' -exec rm -rf "{}" \;
	#echo bonjour
	fi
fi
