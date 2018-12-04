#!/bin/bash
# call 디렉토리의 BP*.toml 을 읽어 서버 부트

BP_NAME=""
echo $PWD

for file in BP*.toml; do
    echo $file
	BP_NAME=$(echo $file | cut -f 1 -d'.')
	if [ "${BP_NAME}" != "tmpl" -a "${BP_NAME}" != "arglog" ]; then
		echo ${BP_NAME};
		echo "aergosvr --config ./$file >> server_${BP_NAME}.log 2>&1 &"
		aergosvr --config ./$file >> server_${BP_NAME}.log 2>&1 &
	fi
done
