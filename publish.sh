#!/usr/bin/env bash

set -o errexit -o nounset

ROLES=$(fissile show image)
replace=zreigz

for ROLE in ${ROLES}; do

	          
	            new_role=$(echo ${ROLE} | sed "s/splatform/${replace}/")
		    echo $new_role
		    docker tag ${ROLE} $new_role
		    docker push $new_role
done




