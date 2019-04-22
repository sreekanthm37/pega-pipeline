#!/bin/sh
# prpcUtils sh script
#                          Copyright 2017  Pegasystems Inc.                           
#                                 All rights reserved.                                 
# This software has been provided pursuant to a License Agreement containing restrictions
# on its use. The software contains valuable trade secrets and proprietary information of
# Pegasystems Inc and is protected by federal copyright law.It may not be copied, modified,
# translated or distributed in any form or medium, disclosed to third parties or used in 
# any manner not provided for in  said License Agreement except with  written
# authorization from Pegasystems Inc.


# Wrapper for the command line prpcUtils contained in prpcUtils.xml

# shellcheck source=posixUtils.sh
. "$(dirname "$0")/../posixUtils.sh"

usage() {
	echo "prpcServiceUtils.sh export | expose | hotfix | import | getStatus | manageTrackedData | rollback | manageRestorePoints | updateAccessGroup | help [options...]"
	echo ""
	echo "Options:"	
	echo "  --connProp          FilePath to connection.properties to operate on multiple instances."
	echo "  --propFile          Location of prpcServiceUtils.properties file. Defaults to ./prpcServiceUtils.properties"
	echo "  --poolSize          Thread pool size"
	echo "  --requestTimeOut    Request TimeOut"
	echo "  --jobIdFile         Path to the JobIds file generated by EXPORT/IMPORT/EXPOSE/HOTFIX operation"		
	echo "  --operationName     Operation name to be queried for getStatus. import, export, expose, and rollback are the valid operation names"
	echo "  --artifactsDir      Specify directory where all the service response artifacts like attachments, service operation logs are stored."
	exit 1
}

if [ -z "$JAVA_HOME" ] ; then
        echo "The JAVA_HOME environment variable must be defined."
        exit 1
fi

# get tool type (export, import, etc.)
# tool type must coincide with an ant target in prpcUtils.xml
TOOL_TYPE=""
case "$1"
in
        "export")				TOOL_TYPE="export";;
        "expose")				TOOL_TYPE="expose";;
        "hotfix")				TOOL_TYPE="hotfix";;
		"import")        	    TOOL_TYPE="import";;
		"getStatus")        	TOOL_TYPE="getstatus";;
		"manageTrackedData")    TOOL_TYPE="manageTrackedData";;
		"rollback")    			TOOL_TYPE="rollback";;
		"manageRestorePoints")  TOOL_TYPE="manageRestorePoints";;
		"updateAccessGroup")  	TOOL_TYPE="updateAccessGroup";;
        "help")					usage;;
        "--help")				usage;;
        *)               		echo "Unknown tool type $1"
                         		usage;;
esac
shift


ANT_PROPS=""
while [ "$1" != "" ]
do
        case "$1"
        in
                "--requestTimeOut")  shift
								 ANT_PROPS="$ANT_PROPS -Dprpcserviceutils.request.timeout=\"$(escape "$1")\"";;
				"--poolSize") shift
								 ANT_PROPS="$ANT_PROPS -Dprpcserviceutils.pool.size=\"$(escape "$1")\"";;
				"--connPropFile") shift
								 ANT_PROPS="$ANT_PROPS -Dprpcserviceutils.connection.filepath=\"$(escape "$1")\"";;
                "--propFile")    shift
                                 ANT_PROPS="$ANT_PROPS -Dprpc.service.utils.custom.property.filepath=\"$(escape "$1")\"";;
				"--jobIdFile") shift
								 ANT_PROPS="$ANT_PROPS -Doperation.specific.file.path=\"$(escape "$1")\"";;
				"--operationName") shift
								 ANT_PROPS="$ANT_PROPS -Dgetstatus.operationName=\"$(escape "$1")\"";;
				"--artifactsDir") shift
								 ANT_PROPS="$ANT_PROPS -Dservice.responseartifacts.dir=\"$(escape "$1")\"";;
                "--help")        usage;;
                *)               echo "Unknown setting $1"
                                 usage;;
        esac
        shift
done

TIMESTAMP=$(date +'%h-%d-%Y-%H-%M-%S')
ANT_PROPS="$ANT_PROPS -Dprpc.service.util.action=$TOOL_TYPE"
ANT_PROPS="$ANT_PROPS -Dlogfile.timestamp=$TIMESTAMP"
logfile=${0%/*}/logs/CLI-prpcServiceUtils-log-$(date +'%h-%d-%Y-%H-%M-%S').log
mkdir -p "${0%/*}/logs"
# Run Ant, given the configuration we collected
run eval "\"$(dirname "$0")/../bin/ant\"" "$ANT_PROPS" -f "\"${0%/*}/prpcServiceUtilsWrapper.xml\"" performOperation 2>&1 \| tee "$logfile"


if [ "$pipestatus_1" -ne 0 ] ; then
        echo "Ant Process returned a non 0 value"
        exit 1
	else
		exit 0
fi