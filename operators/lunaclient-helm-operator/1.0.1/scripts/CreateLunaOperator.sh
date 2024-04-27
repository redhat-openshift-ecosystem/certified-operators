#! /bin/bash

export LC_ALL=C; unset LANGUAGE

	#EXPLICITELY GETTING THE PRESENT WORKING DIRECTORY
	#ALSO "$PWD" CAN BE USED DIRECTLY
export PWD=`pwd`

	#CHECKING IF CHRYSTOKI.CONF FILE IS PRESENT IN THE DEFAULT [/etc/Chrystoki.conf], AND COPY IT TO [/] LOCATION
if [ -f /etc/Chrystoki.conf ]
then
	cp /etc/Chrystoki.conf "$PWD/Chrystoki.conf"
fi

	#CHECKING IF CHRYSTOKI.CONF IS PRESENT AT [/] LOCATION AND ABORT THE SCRIPT IF IT IS NOT PRESENT
if [ ! -f "$PWD/Chrystoki.conf" ]
then
	printf "\nLUNACLIENT CONFIGURATION FILE [Chrystoki.conf] NOT PRESENT AT [$PWD] LOCATION AS [$PWD/Chrystoki.conf]. COPY THE LUNACLIENT CONFIGURATION FILE [Chrystoki.conf] AT [$PWD] LOCATION. ABORTING SCRIPT EXECUTION ! \n"
	exit 1
fi

chmod 777 "$PWD/Chrystoki.conf"

	#FETCHING FULL PATH AND FILE NAME FOR CLIENT'S PRIVATE KEY
export Chrystoki_ClientPrivKeyFile_Path=`cat "$PWD/Chrystoki.conf" | grep "ClientPrivKeyFile =" | awk 'BEGIN{FS="="}{print $NF}' | sed 's/^ *//g' | sed 's/ *$//g' | sed 's/;//g'`
export Chrystoki_ClientPrivKeyFile_Name=`cat "$PWD/Chrystoki.conf" | grep "ClientPrivKeyFile =" | sed 's/^ *//g' | sed 's/ *$//g' | awk 'BEGIN{FS="/"}{print $NF}' | sed 's/;//g'`

	#FETCHING FULL PATH AND FILE NAME FOR CLIENT'S CERTIFICATE
export Chrystoki_ClientCertFile_Path=`cat "$PWD/Chrystoki.conf" | grep "ClientCertFile =" | awk 'BEGIN{FS="="}{print $NF}' | sed 's/^ *//g' | sed 's/ *$//g' | sed 's/;//g'`
export Chrystoki_ClientCertFile_Name=`cat "$PWD/Chrystoki.conf" | grep "ClientCertFile =" | sed 's/^ *//g' | sed 's/ *$//g' | awk 'BEGIN{FS="/"}{print $NF}' | sed 's/;//g'`

	#FETCHING FULL PATH AND FILE NAME FOR SERVER CA FILE
export Chrystoki_ServerCAFile_Path=`cat "$PWD/Chrystoki.conf" | grep "ServerCAFile =" | awk 'BEGIN{FS="="}{print $NF}' | sed 's/^ *//g' | sed 's/ *$//g' | sed 's/;//g'`
export Chrystoki_ServerCAFile_Name=`cat "$PWD/Chrystoki.conf" | grep "ServerCAFile =" | sed 's/^ *//g' | sed 's/ *$//g' | awk 'BEGIN{FS="/"}{print $NF}' | sed 's/;//g'`

	#CHECKING IF CLIENT'S PRIVATE KEY FILE IS PRESENT AS PER THE VALUE IN CHRYSTOKI.CONF OR AT [$PWD] LOCATION AND CREATING THE SECRET FOR THE SAME
	#ABORT THE SCRIPT IF THE FILE IS NOT PRESENT AT ANY OF THE LOCATIONS
if [ ! -f "$Chrystoki_ClientPrivKeyFile_Path" ] && [ ! -f "$Chrystoki_ClientCertFile_Path" ]
then
	if [ ! -f "$PWD/$Chrystoki_ClientPrivKeyFile_Name" ] && [ ! -f "$PWD/$Chrystoki_ClientCertFile_Name" ]
	then
		printf "\nCLIENT'S PRIVATE KEY FILE [$Chrystoki_ClientPrivKeyFile_Name] AND CLIENT'S CERTIFICATE FILE [$Chrystoki_ClientCertFile_Name] NOT PRESENT AT [$PWD] LOCATION. IF LUNACLIENT IS NOT INSTALLED ON THIS HOST OR NTLS IS NOT SETUP ON THIS NODE THEN COPY THE FILE [$Chrystoki_ClientPrivKeyFile_Name] AND [$Chrystoki_ClientCertFile_Name] AT [$PWD] LOCATION. ABORTING SCRIPT EXECUTION ! \n"
		exit 1
	else
		chmod 777 "$PWD/$Chrystoki_ClientCertFile_Name"
		chmod 777 "$PWD/$Chrystoki_ClientPrivKeyFile_Name"
		printf "\nCREATING SECRET FOR CLIENT'S PRIVATE KEY AND CERTIFICATE ... \n"
		kubectl create secret generic operator-luna-client-secret --from-file="$PWD/$Chrystoki_ClientCertFile_Name" --from-file="$PWD/$Chrystoki_ClientPrivKeyFile_Name"
		#echo kubectl create secret generic operator-luna-client-secret --from-file="$PWD/$Chrystoki_ClientCertFile_Name" --from-file="$PWD/$Chrystoki_ClientPrivKeyFile_Name"
	fi
else
	chmod 777 "$Chrystoki_ClientCertFile_Path"
	chmod 777 "$Chrystoki_ClientPrivKeyFile_Path"
	printf "\nCREATING SECRET FOR CLIENT'S PRIVATE KEY AND CERTIFICATE ... \n"
	kubectl create secret generic operator-luna-client-secret --from-file="$Chrystoki_ClientCertFile_Path" --from-file="$Chrystoki_ClientPrivKeyFile_Path"
	#echo kubectl create secret generic operator-luna-client-secret --from-file=$Chrystoki_ClientCertFile_Path --from-file=$Chrystoki_ClientPrivKeyFile_Path
fi

	#CHECKING IF CLIENT'S CERTIFICATE IS PRESENT AS PER THE VALUE IN CHRYSTOKI.CONF OR AT [$PWD] LOCATION AND CREATING THE SECRET FOR THE SAME
	#ABORT THE SCRIPT IF THE FILE IS NOT PRESENT AT ANY OF THE LOCATIONS
if [ ! -f "$Chrystoki_ServerCAFile_Path" ]
then
	if [ ! -f "$PWD/$Chrystoki_ServerCAFile_Name" ]
	then
		printf "\n[$Chrystoki_ServerCAFile_Name] NOT PRESENT AT [$PWD/$Chrystoki_ServerCAFile_Name]. IF LUNACLIENT IS NOT INSTALLED ON THIS HOST OR NTLS IS NOT SETUP ON THIS NODE THEN COPY THE FILE [$Chrystoki_ServerCAFile_Name] AT [$PWD] LOCATION. ABORTING SCRIPT EXECUTION ! \n"
		exit 1
	else
		chmod 777 "$PWD/$Chrystoki_ServerCAFile_Name"
		printf "\nCREATING SECRET FOR SERVER CA FILE ... \n"
		kubectl create secret generic operator-luna-cafile-secret --from-file="$PWD/$Chrystoki_ServerCAFile_Name"
		#echo kubectl create secret generic operator-luna-cafile-secret --from-file="$PWD/$Chrystoki_ServerCAFile_Name"
	fi
else
	chmod 777 "$Chrystoki_ServerCAFile_Path"
	printf "\nCREATING SECRET FOR SERVER CA FILE ... \n"
	kubectl create secret generic operator-luna-cafile-secret --from-file="$Chrystoki_ServerCAFile_Path"
	#echo kubectl create secret generic operator-luna-cafile-secret --from-file="$Chrystoki_ServerCAFile_Path"
fi

####################################################################################################################################

	#FETCHING THE LibUNIX ENTRY FROM CHRYSTOKI.CONF FILE AND STORING IT IN A VARIABLE
	#STORING THE NEW VALUE WHICH WILL REPLACE THE OLD LibUNIX IN A VARIABLE
export Chrystoki_LibUNIX=`cat "$PWD/Chrystoki.conf" | grep "LibUNIX =" | sed 's/^ *//g' | sed 's/ *$//g'`
export New_Chrystoki_LibUNIX='LibUNIX = /var/usrlocal/luna/libs/64/libCryptoki2.so;'

	#FETCHING THE LibUNIX64 ENTRY FROM CHRYSTOKI.CONF FILE AND STORING IT IN A VARIABLE
	#STORING THE NEW VALUE WHICH WILL REPLACE THE OLD LibUNIX64 IN A VARIABLE
export Chrystoki_LibUNIX64=`cat "$PWD/Chrystoki.conf" | grep "LibUNIX64 =" | sed 's/^ *//g' | sed 's/ *$//g'`
export New_Chrystoki_LibUNIX64='LibUNIX64 = /var/usrlocal/luna/libs/64/libCryptoki2_64.so;'

	#FETCHING THE SSLConfigFile ENTRY FROM CHRYSTOKI.CONF FILE AND STORING IT IN A VARIABLE
	#STORING THE NEW VALUE WHICH WILL REPLACE THE OLD SSLConfigFile IN A VARIABLE
export Chrystoki_SSLConfigFile=`cat "$PWD/Chrystoki.conf" | grep "SSLConfigFile =" | sed 's/^ *//g' | sed 's/ *$//g'`
export New_Chrystoki_SSLConfigFile='SSLConfigFile = /var/usrlocal/luna/openssl.cnf;'

	#FETCHING THE ClientPrivKeyFile ENTRY FROM CHRYSTOKI.CONF FILE AND STORING IT IN A VARIABLE
	#FETCHING THE ClientPrivKeyFile NAME FROM ClientPrivKeyFile ENTRY IN CHRYSTOKI.CONF FILE
	#STORING THE NEW VALUE WHICH WILL REPLACE THE OLD ClientPrivKeyFile IN A VARIABLE
export Chrystoki_ClientPrivKeyFile=`cat "$PWD/Chrystoki.conf" | grep "ClientPrivKeyFile =" | sed 's/^ *//g' | sed 's/ *$//g'`
export Chrystoki_ClientPrivKeyFile_Name=`cat "$PWD/Chrystoki.conf" | grep "ClientPrivKeyFile =" | sed 's/^ *//g' | sed 's/ *$//g' | awk 'BEGIN{FS="/"}{print $NF}' | sed 's/;//g'`
export New_Chrystoki_ClientPrivKeyFile="ClientPrivKeyFile = /var/usrlocal/luna/cert/client/$Chrystoki_ClientPrivKeyFile_Name;"

	#FETCHING THE ClientCertFile ENTRY FROM CHRYSTOKI.CONF FILE AND STORING IT IN A VARIABLE
	#FETCHING THE ClientCertFile NAME FROM ClientCertFile ENTRY IN CHRYSTOKI.CONF FILE
	#STORING THE NEW VALUE WHICH WILL REPLACE THE OLD ClientCertFile IN A VARIABLE
export Chrystoki_ClientCertFile=`cat "$PWD/Chrystoki.conf" | grep "ClientCertFile =" | sed 's/^ *//g' | sed 's/ *$//g'`
export Chrystoki_ClientCertFile_Name=`cat "$PWD/Chrystoki.conf" | grep "ClientCertFile =" | sed 's/^ *//g' | sed 's/ *$//g' | awk 'BEGIN{FS="/"}{print $NF}' | sed 's/;//g'`
export New_Chrystoki_ClientCertFile="ClientCertFile = /var/usrlocal/luna/cert/client/$Chrystoki_ClientCertFile_Name;"

	#FETCHING THE ServerCAFile ENTRY FROM CHRYSTOKI.CONF FILE AND STORING IT IN A VARIABLE
	#STORING THE NEW VALUE WHICH WILL REPLACE THE OLD ServerCAFile IN A VARIABLE
export Chrystoki_ServerCAFile=`cat "$PWD/Chrystoki.conf" | grep "ServerCAFile =" | sed 's/^ *//g' | sed 's/ *$//g'`
export New_Chrystoki_ServerCAFile="ServerCAFile = /var/usrlocal/luna/cert/server/CAFile.pem;"

	#FETCHING THE ToolsDir ENTRY FROM CHRYSTOKI.CONF FILE AND STORING IT IN A VARIABLE
	#STORING THE NEW VALUE WHICH WILL REPLACE THE OLD ToolsDir IN A VARIABLE
export Chrystoki_ToolsDir=`cat "$PWD/Chrystoki.conf" | grep "ToolsDir =" | sed 's/^ *//g' | sed 's/ *$//g'`
export New_Chrystoki_ToolsDir="ToolsDir = /var/usrlocal/luna/bin/64;"

	#FETCHING THE PartitionPolicyTemplatePath ENTRY FROM CHRYSTOKI.CONF FILE AND STORING IT IN A VARIABLE
	#STORING THE NEW VALUE WHICH WILL REPLACE THE OLD PartitionPolicyTemplatePath IN A VARIABLE
export Chrystoki_PartitionPolicyTemplatePath=`cat "$PWD/Chrystoki.conf" | grep "PartitionPolicyTemplatePath =" | sed 's/^ *//g' | sed 's/ *$//g'`
export New_Chrystoki_PartitionPolicyTemplatePath="PartitionPolicyTemplatePath = /var/usrlocal/luna/ppt/partition_policy_templates;"

	#FETCHING THE ClientTokenLib ENTRY FROM CHRYSTOKI.CONF FILE AND STORING IT IN A VARIABLE
	#STORING THE NEW VALUE WHICH WILL REPLACE THE OLD ClientTokenLib IN A VARIABLE
export Chrystoki_ClientTokenLib=`cat "$PWD/Chrystoki.conf" | grep "ClientTokenLib =" | sed 's/^ *//g' | sed 's/ *$//g'`
export New_Chrystoki_ClientTokenLib="ServerCAFile = /var/usrlocal/luna/libs/64/libSoftToken.so;"

	#FETCHING THE SoftTokenDir ENTRY FROM CHRYSTOKI.CONF FILE AND STORING IT IN A VARIABLE
	#STORING THE NEW VALUE WHICH WILL REPLACE THE OLD SoftTokenDir IN A VARIABLE
export Chrystoki_SoftTokenDir=`cat "$PWD/Chrystoki.conf" | grep "SoftTokenDir =" | sed 's/^ *//g' | sed 's/ *$//g'`
export New_Chrystoki_SoftTokenDir="SoftTokenDir = /var/usrlocal/luna/stc/token;"

	#FETCHING THE ClientIdentitiesDir ENTRY FROM CHRYSTOKI.CONF FILE AND STORING IT IN A VARIABLE
	#STORING THE NEW VALUE WHICH WILL REPLACE THE OLD ClientIdentitiesDir IN A VARIABLE
export Chrystoki_ClientIdentitiesDir=`cat "$PWD/Chrystoki.conf" | grep "ClientIdentitiesDir =" | sed 's/^ *//g' | sed 's/ *$//g'`
export New_Chrystoki_ClientIdentitiesDir="ClientIdentitiesDir = /var/usrlocal/luna/stc/client_identities;"

	#FETCHING THE PartitionIdentitiesDir ENTRY FROM CHRYSTOKI.CONF FILE AND STORING IT IN A VARIABLE
	#STORING THE NEW VALUE WHICH WILL REPLACE THE OLD PartitionIdentitiesDir IN A VARIABLE
export Chrystoki_PartitionIdentitiesDir=`cat "$PWD/Chrystoki.conf" | grep "PartitionIdentitiesDir =" | sed 's/^ *//g' | sed 's/ *$//g'`
export New_Chrystoki_PartitionIdentitiesDir="PartitionIdentitiesDir = /var/usrlocal/luna/stc/partition_identities;"

	#REPLACING OLD ENTRIES WITH NEW ENTRIES AS FETCHED ABOVE AND CREATING A NEW CHRYSTOKI.CONF FILE FOR THE CONTAINER/POD
printf "\nCREATING LUNACLIENT CONFIG FILE FOR POD/CONTAINER FOR K8S/OPENSHIFT ENVIRONMENT ... \n" 
sed -i "s|$Chrystoki_LibUNIX|$New_Chrystoki_LibUNIX|g" "$PWD/Chrystoki.conf"
sed -i "s|$Chrystoki_LibUNIX64|$New_Chrystoki_LibUNIX64|g" "$PWD/Chrystoki.conf"
sed -i "s|$Chrystoki_SSLConfigFile|$New_Chrystoki_SSLConfigFile|g" "$PWD/Chrystoki.conf"
sed -i "s|$Chrystoki_ClientPrivKeyFile|$New_Chrystoki_ClientPrivKeyFile|g" "$PWD/Chrystoki.conf"
sed -i "s|$Chrystoki_ClientCertFile|$New_Chrystoki_ClientCertFile|g" "$PWD/Chrystoki.conf"
sed -i "s|$Chrystoki_ServerCAFile|$New_Chrystoki_ServerCAFile|g" "$PWD/Chrystoki.conf"
sed -i "s|$Chrystoki_ToolsDir|$New_Chrystoki_ToolsDir|g" "$PWD/Chrystoki.conf"
sed -i "s|$Chrystoki_PartitionPolicyTemplatePath|$New_Chrystoki_PartitionPolicyTemplatePath|g" "$PWD/Chrystoki.conf"
sed -i "s|$Chrystoki_ClientTokenLib|$New_Chrystoki_ClientTokenLib|g" "$PWD/Chrystoki.conf"
sed -i "s|$Chrystoki_SoftTokenDir|$New_Chrystoki_SoftTokenDir|g" "$PWD/Chrystoki.conf"
sed -i "s|$Chrystoki_ClientIdentitiesDir|$New_Chrystoki_ClientIdentitiesDir|g" "$PWD/Chrystoki.conf"
sed -i "s|$Chrystoki_PartitionIdentitiesDir|$New_Chrystoki_PartitionIdentitiesDir|g" "$PWD/Chrystoki.conf"

printf "\nCREATING SECRET FOR LUNACLIENT CONFIGURATION FILE [Chrystoki.conf] ... \n"
kubectl create secret generic operator-luna-config-secret --from-file="$PWD/Chrystoki.conf"
#echo kubectl create secret generic operator-luna-config-secret --from-file="$PWD/Chrystoki.conf"

####################################################################################################################################

echo