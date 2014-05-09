#! /bin/sh
PID=$$
path="./atom"
output="./json/"
for ff in `ls ${path}/*.xml`
	do
	name=`basename $ff | sed 's#\.xml##g'`
	xsltproc ./xslt/owc2geojson.xsl ${ff}  > ${output}${name}.json
done


