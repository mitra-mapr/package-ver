#!/bin/bash
WORKSPACE=$1
if [ -z "$1" ]; then
  echo Please provide a path
  exit 1
fi

# Launch the Containers and get IP of the node
centos_containerid=$(docker run -d --privileged  -v $WORKSPACE:/package_ver maprdocker.lab/pkgverify_centos:6.7 /package_ver/scripts/centos_prep.sh)
ubuntu_containerid=$(docker run -d --privileged  -v $WORKSPACE:/package_ver maprdocker.lab/pkgverify_ubuntu:12.04 /package_ver/scripts/ubuntu_prep.sh)


sleep 20
centos_containerip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${centos_containerid} )
ubuntu_containerip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${ubuntu_containerid} )
#echo " Container Node IP : $containerip		login:root   password:mapr"

sleep 60

for line in $(cat $WORKSPACE/scripts/list)
do
	echo $line
	case "$line" in
	*centos*)
		echo centos
		sshpass -p "mapr" ssh -o LogLevel=quiet -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${centos_containerip} /package_ver/scripts/centos_verify.sh $line $centos_containerid
		;;
	*ubuntu*)
		echo ubuntu
		sshpass -p "mapr" ssh -o LogLevel=quiet -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${ubuntu_containerip} /package_ver/scripts/ubuntu_verify.sh $line $ubuntu_containerid
		;;
	esac
done
