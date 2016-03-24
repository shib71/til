#!/bin/bash

# TODO
#
# - flight check for docker/docker-machine/docker-compose/vboxmanage
# - flight check for running vm before
# - only show the "eval" hint if the docker machine name doesn't match the current workbench
#

VERSION="v0.2"

BOOT2DOCKER_ISO_VERSION=1.10.1
DOCKER_COMPOSE_VERSION=1.6.0

WORKINGDIR=$(pwd)
WORKINGDIRNAME=$(basename $WORKINGDIR)

SHARED_FOLDER=$WORKINGDIR
MACHINE_NAME=$WORKINGDIRNAME


function showUsage {
	echo "Docker Workbench $VERSION"
	echo "Provision a Docker Workbench for use with docker-machine and docker-compose"
	echo
	echo "Usage:"
	echo "  docker-workbench [options] [COMMAND]"
	echo
	echo "Options:"
	echo "    -v, --version   Print version and exit"
	echo "    -h, --help      Print help usage"
	echo
	echo "Commands:"
	echo "  create            Create a new workbench machine in the current directory"
	echo "  up                Start the workbench machine and show details"
	echo

	exit 2
}

function showVersion {
	echo "$VERSION"
	exit 0
}


function fixPath {
	local folderPath=`echo "${1}"`
	folderPath=${folderPath/c\:/\/c}
	folderPath=${folderPath/C\:/\/c}
	folderPath=${folderPath/d\:/\/d}
	folderPath=${folderPath/D\:/\/d}
	folderPath=${folderPath//\\/\/}
	folderPath=${folderPath/Program Files/Progra~1}
	echo "$folderPath"
}


MACHINE_STORAGE_PATH=$(fixPath $MACHINE_STORAGE_PATH)

# use a local cached boot2docker iso if it is available
BOOT2DOCKER_ISO_URL=https://github.com/boot2docker/boot2docker/releases/download/v$BOOT2DOCKER_ISO_VERSION/boot2docker.iso
BOOT2DOCKER_ISO_FILE=cache/boot2docker-$BOOT2DOCKER_ISO_VERSION.iso
BOOT2DOCKER_ISO=$BOOT2DOCKER_ISO_URL
if [ -f $MACHINE_STORAGE_PATH/$BOOT2DOCKER_ISO_FILE ]
	then
	BOOT2DOCKER_ISO=file:/$MACHINE_STORAGE_PATH/$BOOT2DOCKER_ISO_FILE
fi

# get the path to the vboxmanage executable
if [[ "$VBOX_INSTALL_PATH" ]]
	then
	VBOX_MANAGE=$(fixPath "$VBOX_INSTALL_PATH/VBoxManage")
elif [[ "$VBOX_MSI_INSTALL_PATH" ]]
	then
	VBOX_MANAGE=$(fixPath "$VBOX_MSI_INSTALL_PATH/VBoxManage")
else
	VBOX_MANAGE="VBoxManage"
fi


function isMachineCreated {
 	if [[ -z $($VBOX_MANAGE list vms | grep \"$MACHINE_NAME\") ]]
 		then
 		echo "false"
 	else
		echo "true"
 	fi
}

function isMachineRunning {
	if [[ -z $($VBOX_MANAGE list runningvms | grep \"$MACHINE_NAME\") ]]
 		then
 		echo "false"
 	else
		echo "true"
 	fi
}


function commandCreate {

	# create a new docker machine
	if [[ $(isMachineCreated) =~ "false" ]]
		then

		# create the docker machine
		docker-machine create --driver virtualbox \
			--virtualbox-cpu-count "2" \
			--virtualbox-memory "2048" \
			--virtualbox-no-share \
			--virtualbox-boot2docker-url $BOOT2DOCKER_ISO \
			$MACHINE_NAME
		eval "$(docker-machine env $MACHINE_NAME)"

		echo "Configuring bootsync.sh..."
		# mount the /workbench share
		docker-machine ssh $MACHINE_NAME "sudo echo 'sudo mkdir -p /workbench && sudo mount -t vboxsf -o uid=1000,gid=50 workbench /workbench' >  /tmp/bootsync.sh"
		# write to bootsync.sh to configure persistent startup settings
		docker-machine ssh $MACHINE_NAME "sudo cp /tmp/bootsync.sh /var/lib/boot2docker/bootsync.sh"
		docker-machine ssh $MACHINE_NAME "sudo chmod +x /var/lib/boot2docker/bootsync.sh"

		#echo "Installing Workbench Apps..."
		docker-machine ssh $MACHINE_NAME "docker run -d --restart=always --name=workbench_proxy -p 80:80 -v '/var/run/docker.sock:/tmp/docker.sock:ro' daemonite/workbench-proxy"
		docker-machine ssh $MACHINE_NAME "docker run -d --restart=always --name=docker_vhosts -e VIRTUAL_HOST='workbench.*' -v '/var/run/docker.sock:/tmp/docker.sock:ro' texthtml/docker-vhosts"
		docker-machine ssh $MACHINE_NAME "docker run -d --restart=always --name=dockerui -p 81:9000 --privileged -v '/var/run/docker.sock:/var/run/docker.sock' dockerui/dockerui"

		# stop the machine
		docker-machine stop $MACHINE_NAME

		# add shared folder
		echo "Adding /workbench shared folder..."
		$VBOX_MANAGE sharedfolder add "$MACHINE_NAME" --name "workbench" --hostpath "$SHARED_FOLDER"

	fi

	startMachine "$MACHINE_NAME"

	MACHINE_IP=$(docker-machine ip $MACHINE_NAME)

	echo
	echo "Browse the workbench Docker UI:"
	echo "http://workbench.${MACHINE_IP}.xip.io/"
}

function commandUp {

	if [[ $(isMachineCreated) =~ "true" ]]
		then
		# working dir is a workbench directory
		startMachine "$MACHINE_NAME"

		APPDIRNAME=$MACHINE_NAME
		MACHINE_IP=$(docker-machine ip $MACHINE_NAME)
		echo
		echo "Browse the Workbench:"
		echo "http://${APPDIRNAME}.${MACHINE_IP}.xip.io/"
	else
		# working dir is an application directory
		APPDIRNAME=$WORKINGDIRNAME
		WORKBENCHDIRPATH=$(dirname $WORKINGDIR)
		MACHINE_NAME=$(basename $WORKBENCHDIRPATH)
		if [[ $(isMachineCreated) =~ "true" ]]
			then
			startMachine "$MACHINE_NAME"

			# check if app is running
			if [[ -z $(docker ps | grep $APPDIRNAME) ]]
				then
				echo
				echo "Start the application:"
				echo "docker-compose up"
			fi

			MACHINE_IP=$(docker-machine ip $MACHINE_NAME)
			echo
			echo "Browse the \"${APPDIRNAME}\" application:"
			echo "http://${APPDIRNAME}.${MACHINE_IP}.xip.io/"
		else
			echo "Workbench machine not found."
		fi
	fi

}


function startMachine {
	if [[ $(isMachineRunning) =~ "false" ]]
		then
		docker-machine start $1
	fi
	eval "$(docker-machine env $1)"

	echo
	echo "Run the following command to set this machine as your default:"
	echo "eval \"\$(docker-machine env $1)\""
}

# clean
#docker rmi -f $(docker images -q -a -f dangling=true)


##### main

# global options

while : 
do
	if [[ "$1" == --* ]]
		then
		case $1 in
			"--help" ) showUsage;;
			"--version" ) showVersion;;
			* ) echo "Error: unknown option $1"; echo; showUsage;;
		esac
	else
		break
	fi
done

# command line arguments
COMMAND=$1

# show usage
if [ "$COMMAND" == "-h" ] ;	then showUsage; fi
# show version
if [ "$COMMAND" == "-v" ] ;	then showVersion; fi

# show usage for unknown commands
if [ "$COMMAND" != "create" ] && [ "$COMMAND" != "up" ] #&& [ "$COMMAND" != "ssh" ] && [ "$COMMAND" != "start" ] && [ "$COMMAND" != "stop" ]
	then
	if [ ! "$COMMAND" == "" ]
		then
		echo "Error: unknown command '$1'"
		echo
	fi
	showUsage
fi

echo "Docker Workbench $VERSION"

if [ "$COMMAND" == "create" ] 
	then
	commandCreate "$@"
elif [ "$COMMAND" == "up" ] 
 	then
	commandUp "$@"
fi

exit 0
