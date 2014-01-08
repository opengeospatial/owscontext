#! /bin/sh
PID=$$
path="../examples/atom"
output="../examples/json/"
for ff in `ls ${path}/*.xml`
	do
	name=`basename $ff | sed 's#\.xml##g'`
	xsltproc ../xslt/owc2geojson.xsl ${ff}  > ${output}${name}.json
done


