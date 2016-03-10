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

# 1. Set-up Repos and import gpg signature keys

/bin/rm -f /etc/yum.repos.d/mapr*
/usr/bin/yum clean all

echo "[MapR_Core]
name = MapR Core Components
enabled = 1
baseurl = http://package.qa.lab/releases/v5.1.0/redhat
protected = 1
gpgcheck = 1 " >> /etc/yum.repos.d/mapr_core.repo

echo "[MapR_Ecosystem]
name = MapR Ecosystem Components
enabled = 1
baseurl = http://package.qa.lab/releases/ecosystem-${ecosystem}/redhat
protected = 1
gpgcheck = 0 " >> /etc/yum.repos.d/mapr_ecosystem.repo


# 2. Install the 'default' package. List the version.

if /usr/bin/yum install -y ${component} ; then
	echo " Default install: ${component} INSTALLED" >> ${logfile}
	#defaultVer=$(/usr/bin/yum list installed ${component} | awk '{ print $2 }')
	defaultVer=$(/usr/bin/yum info installed ${component} | grep Version | cut -d":" -f2 )
	echo " Default install - Version installed : ${defaultVer}" >> ${logfile}
else
	echo "Default install: ${component} NOT INSTALLED" >> ${logfile}
fi

# 3. Remove the 'default' installation; yum clean
if /usr/bin/yum remove -y ${component} ; then
        echo " Default install: ${component} REMOVED" >> ${logfile}
else 
	echo " Default install : ${component} NOT REMOVED" >> ${logfile}
fi

echo " ">> ${logfile}

/usr/bin/yum clean all

# 4. Install the 'component-version' 

if /usr/bin/yum install -y ${component}-${version} ; then
	echo " Version install: ${component}-${version} INSTALLED" >> ${logfile}
	#installedVer=$(/usr/bin/yum list installed ${component} | awk '{ print $2 }')
	installedVer=$(/usr/bin/yum info installed ${component} | grep Version | cut -d":" -f2 )
	echo " Version install - Requested version : ${version}" >> ${logfile}
	echo " Version install - Installed version : ${installedVer}" >> ${logfile}
else
	echo " Version install: ${component}-${version} NOT INSTALLED" >> ${logfile}
fi


# 5. Remove the 'compnent-version' install; yum clean

if /usr/bin/yum remove -y ${component}-${version} ; then
        echo " Version install: ${component}-${version} REMOVED" >> ${logfile}
else 
	echo " Version install : ${component}-${version} NOT REMOVED" >> ${logfile}
fi

/usr/bin/yum clean all

echo "========================================================" >> ${logfile}
echo " ">> ${logfile}

