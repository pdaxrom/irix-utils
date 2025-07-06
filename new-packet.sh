#!/bin/bash

echo -ne "\nCreate new rules file from template:\n"
echo -ne "------------------------------------\n\n"

echo -ne "Name of new packet..........: "
read name
echo -ne "Version number..............: "
read version
echo -ne "Archive file suffix.........: "
read suffix
echo -ne "URL of download directory...: "
read url
echo -ne "Description.................: "
read description
#echo -ne "Packet Author...............: "
#read author
echo -ne "Patch(es)...................: "
read patches

pushd rules

filename=$(echo $name | tr '-' '_')

cp TEMPLATE ${filename}.sh
sed -i "s|@PKG_NAME@|$name|"		${filename}.sh
sed -i "s|@PKG_VERSION@|$version|"	${filename}.sh
sed -i "s|@PKG_URL@|$url|"		${filename}.sh
sed -i "s|@PKG_EXT@|$suffix|"		${filename}.sh
sed -i "s|@PKG_DESC@|$description|"	${filename}.sh
sed -i "s|@PKG_PATCH@|$patches|"	${filename}.sh
sed -i '/^build/s/-/_/g' ${filename}.sh

popd
