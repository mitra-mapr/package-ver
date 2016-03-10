#!/bin/bash

# Expecting $1 as comp:ver:ecosys:os , and $2 as logfilename
line=$1
filename=$2

declare -a list
list=(${line//:/ })

component=${list[0]}
version=${list[1]}
ecosystem=${list[2]}
logfile=/package_ver/output/${filename}


echo "========================================================" >> ${logfile}
echo " Component Name : ${line} " >> ${logfile}
echo " " >> ${logfile}

# 1. Set-up Repos 

/bin/cp /etc/apt/sources.list.org /etc/apt/sources.list

echo "deb http://package.qa.lab/releases/v5.1.0/ubuntu/ mapr optional" >> /etc/apt/sources.list
echo "deb http://package.qa.lab/releases/ecosystem-${ecosystem}/ubuntu binary/" >> /etc/apt/sources.list

/usr/bin/apt-get update

# 2. Install the 'default' package. List the version.

if /usr/bin/apt-get -y --force-yes install ${component} ; then
	echo " Default install: ${component} INSTALLED" >> ${logfile}
	defaultVer=$(/usr/bin/dpkg -s ${component} | grep Version | awk '{ print $2 }' )
	echo " Default install - Version installed : ${defaultVer}" >> ${logfile}
else
	echo "Default install: ${component} NOT INSTALLED" >> ${logfile}
fi

# 3. Remove the 'default' installation; yum clean
if /usr/bin/apt-get remove -y ${component} ; then
        echo " Default install: ${component} REMOVED" >> ${logfile}
else 
	echo " Default install : ${component} NOT REMOVED" >> ${logfile}
fi

echo " ">> ${logfile}

/usr/bin/apt-get update

# 4. Install the 'component-version' 

if /usr/bin/apt-get -y --force-yes install  ${component}-${version} ; then
	echo " Version install: ${component}-${version} INSTALLED" >> ${logfile}
        installedVer=$(/usr/bin/dpkg -s ${component} | grep Version | awk '{ print $2 }' )
	echo " Version install - Requested version : ${version}" >> ${logfile}
	echo " Version install - Installed version : ${installedVer}" >> ${logfile}
else
	echo " Version install: ${component}-${version} NOT INSTALLED" >> ${logfile}
fi


# 5. Remove the 'compnent-version' install; yum clean

if /usr/bin/apt-get remove -y ${component}-${version} ; then
        echo " Version install: ${component}-${version} REMOVED" >> ${logfile}
else 
	echo " Version install : ${component}-${version} NOT REMOVED" >> ${logfile}
fi

/usr/bin/apt-get update

echo "========================================================" >> ${logfile}
echo " ">> ${logfile}

