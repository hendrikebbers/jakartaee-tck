#!/bin/bash -x

export TCK_HOME=${WORKSPACE}
echo "TCK_HOME in jsonbtck.sh $TCK_HOME"
echo "ANT_HOME in jsonbtck.sh $ANT_HOME"
echo "PATH in jsonbtck.sh $PATH"
echo "ANT_OPTS in jsonbtck.sh $ANT_OPTS"

cd $TCK_HOME

if [ -f "${WORKSPACE}/standalone-bundles/jsonbtck-1.0_latest.zip" ];then
  echo "Using stashed bundle created during the build phase"
else
  echo "Download and install JSONB TCK Bundle ..."
  mkdir -p ${WORKSPACE}/standalone-bundles
  wget http://blr00akv.in.oracle.com/tck-builds/links/builds/tcks/javaee_cts/8.1/nightly/jsonbtck-1.0_Latest.zip -O ${WORKSPACE}/standalone-bundles/jsonbtck-1.0_latest.zip
fi
unzip ${WORKSPACE}/standalone-bundles/jsonbtck-1.0_latest.zip -d ${TCK_HOME}

##### installRI.sh starts here #####
echo "Download and install GlassFish 5.0.1 ..."
if [ -z "${GF_BUNDLE_URL}" ]; then
  export GF_BUNDLE_URL="http://download.oracle.com/glassfish/5.0.1/nightly/latest-glassfish.zip"
fi
wget --progress=bar:force --no-cache $GF_BUNDLE_URL -O latest-glassfish.zip
unzip ${TCK_HOME}/latest-glassfish.zip -d ${TCK_HOME}

TS_HOME=$TCK_HOME/jsonbtck
echo "TS_HOME $TS_HOME"

chmod -R 777 $TS_HOME
cd $TS_HOME/bin

sed -i "s#^report.dir=.*#report.dir=$TCK_HOME/jsonbtckreport/jsonbtck#g" ts.jte
sed -i "s#^work.dir=.*#work.dir=$TCK_HOME/jsonbtckwork/jsonbtck#g" ts.jte
sed -i "s#jsonb\.classes=.*#jsonb.classes=$TCK_HOME/glassfish5/glassfish/modules/javax.json.bind-api.jar:$TCK_HOME/glassfish5/glassfish/modules/javax.json.jar:$TCK_HOME/glassfish5/glassfish/modules/javax.inject.jar:$TCK_HOME/glassfish5/glassfish/modules/javax.servlet-api.jar:$TCK_HOME/glassfish5/glassfish/modules/yasson.jar#" ts.jte

mkdir -p $TCK_HOME/jsonbtckreport/jsonbtck
mkdir -p $TCK_HOME/jsonbtckwork/jsonbtck

# ant config.vi
cd $TS_HOME/src/com/sun/ts/tests/
#ant deploy.all
ant run.all
echo "Test run complete"

TCK_NAME=jsonbtck
JT_REPORT_DIR=$TCK_HOME/${TCK_NAME}report
export HOST=`hostname -f`
echo "1 ${TCK_NAME} ${HOST}" > ${WORKSPACE}/args.txt
mkdir -p ${WORKSPACE}/results/junitreports/
${JAVA_HOME}/bin/java -Djunit.embed.sysout=true -jar ${WORKSPACE}/docker/JTReportParser/JTReportParser.jar ${WORKSPACE}/args.txt ${JT_REPORT_DIR} ${WORKSPACE}/results/junitreports/

tar zcvf ${WORKSPACE}/${TCK_NAME}-results.tar.gz ${TCK_HOME}/${TCK_NAME}report ${TCK_HOME}/${TCK_NAME}work ${WORKSPACE}/results/junitreports/

