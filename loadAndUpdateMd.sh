#!/bin/bash
# prepare environment
git pull

# load arguments
version=$1
op5_config=upload.txt
oldFile=$2
releaseNote=changeLog.txt
constOBTParamLength=6

# function definition
# $1 keyword
# $2 fileToWrite
# $3 newValueToWrite
changeLineWithType() {
	keyWord=$1
	fileToWrite=$2
	newValueToWrite="$3"
	rowNum=$(grep ^${keyWord} ${fileToWrite} -n | awk -F ':' '{print $1}')
    newValueToWrite="${keyWord}: "${newValueToWrite}
    echo ${newValueToWrite}
    sed -i "${rowNum}c\
    ${newValueToWrite}" ${fileToWrite}
}

# load old file and save new one with new version number -- done
echo $oldFile
nf=$(ls ${oldFile} | awk -F '_' 'BEGIN{OFS="_";}{print NF}')
if [ ${nf} -ge 5 ]
then
    newFile=$(ls ${oldFile} | awk -F '_' 'BEGIN{OFS="_";}{print $1,$2,$3,$4;}')
else
    newFile=$(ls ${oldFile} | awk -F '_' 'BEGIN{OFS="_";}{print $1,$2,$3;}')
fi
newFile=${newFile}_${version}.md
echo $newFile
cp ${oldFile} ${newFile}

# replace old values copied with new values -- done
# replace old download link
# update download info

downloadLink=$(cat ${op5_config} | grep http: | grep FILE | awk -F ' ' '{print $3}')
echo $downloadLink
oldDownloadLink=$(cat ${newFile} | grep download | awk -F ' ' '{print $2}')
changeLineWithType "download" ${newFile} ${downloadLink}

# update title
titleRow=$(grep ^title ${newFile} -n | awk -F ':' '{print $1}')
titleNF=$(grep ^title ${newFile} | awk -F ' ' '{print NF}')
# if title part larger than 5, it's an open beta to upload
# $1 is dismissed since it's title word itself. we change it with keyword later by using changeLineWithType
if [ ${titleNF} -ge ${constOBTParamLength} ]
then
    newTitle=$(grep ^title ${newFile} | awk -F ' ' 'BEGIN{OFS=" ";}{print $2,$3,$4,$5,$6;}')
    # we change version here if it is an open beta version.
    newTitle=${newTitle}" "${version}
    version="Open Beta "${version}
else
    newTitle=$(grep ^title ${newFile} | awk -F ' ' 'BEGIN{OFS=" ";}{print $2,$3,$4;}')
    newTitle=${newTitle}" "${version}
fi
changeLineWithType "title" ${newFile} "${newTitle}"
# replace version
# replace version in old title -- not yet
# replace version number in version category -- done
# new version is loaded by given version number $1 manually
# rely on title name length to update version. decide whether to insert open beta into it.
changeLineWithType "version" ${newFile} "${version}"

# replace old md5 info -- done
md5=$(cat ${op5_config} | grep '^MD5' | awk -F ' ' '{print $4}')
echo $md5
changeLineWithType "md5" ${newFile} ${md5}

# replace file size -- not yet
# update fileSize info
fileSize=$(cat ${op5_config} | grep "file size" | awk -F ' ' '{print $3}' | sed 's/[^0-9]//g')
fileSize=$(echo $fileSize | awk '{printf ("%.2f\n",$1/1073741824)}')
fileSize=${fileSize}" ""GB"
changeLineWithType "file_size" ${newFile} "${fileSize}"

#update date -- done
date=$(date +%F)
echo $date
changeLineWithType "date" ${newFile} ${date}

# update release contents -- done
# releaseNote contains formatted release contents.
contentsStartingRow=$(grep ^--- ${newFile} -n | awk -F ':' '{print $1}')
contentsStartingRow=$(( ${contentsStartingRow} + 1 ))
echo ${contentsStartingRow}
sed -i "${contentsStartingRow},\$d" ${newFile}
cat $releaseNote >> ${newFile}


#git add ${newFile}
#git commit -m "upload ${newTitle}"
