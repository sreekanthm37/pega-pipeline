#!/bin/sh
# posixUtils sh script
#                          Copyright 2017  Pegasystems Inc.                           
#                                 All rights reserved.                                 
# This software has been provided pursuant to a License Agreement containing restrictions
# on its use. The software contains valuable trade secrets and proprietary information of
# Pegasystems Inc and is protected by federal copyright law.It may not be copied, modified,
# translated or distributed in any form or medium, disclosed to third parties or used in 
# any manner not provided for in  said License Agreement except with written
# authorization from Pegasystems Inc.


#used to run multiple commands and capture all return codes
# shellcheck disable=SC2034
pipestatus_1=-1;
run() {
	j=1
	while eval "\${pipestatus_$j+:} false"; do
		unset pipestatus_$j
		j=$((j+1))
	done
	j=1 com='' k=1 l=''
	for a; do
		if [ "x$a" = 'x|' ]; then
			com="$com { $l "'3>&-
						echo "pipestatus_'$j'=$?" >&3
					  } 4>&- |'
			j=$((j+1)) l=
		else
			l="$l \"\${$k}\""
		fi
		k=$((k+1))
	done
	com="$com $l"' 3>&- >&4 4>&-
				echo "pipestatus_'$j'=$?"'
	exec 4>&1
	eval "$(exec 3>&1; eval "$com")"
	exec 4>&-
	j=1
	while eval "\${pipestatus_$j+:} false"; do
		eval "[ \$pipestatus_$j -eq 0 ]" || return 1
		j=$((j+1))
	done
	return 0
}

# escapes problematic characters in argument values
#  the first sed strips leading and trailing quotes (only if both are present)
#  the second sed escapes back-slashes
#  the third sed escapes double-quotes
escape(){
	echo "$1" | sed 's/\(^"\)\(.*\)\("$\)/\2/' | sed 's/\\/\\\\\\\\/g' | sed 's/"/\\\\\\"/g' 
}
