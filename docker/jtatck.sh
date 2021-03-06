#!/bin/bash -xe

# Copyright (c) 2018 Oracle and/or its affiliates. All rights reserved.
#
# This program and the accompanying materials are made available under the
# terms of the Eclipse Public License v. 2.0, which is available at
# http://www.eclipse.org/legal/epl-2.0.
#
# This Source Code may also be made available under the following Secondary
# Licenses when the conditions for such availability set forth in the
# Eclipse Public License v. 2.0 are satisfied: GNU General Public License,
# version 2 with the GNU Classpath Exception, which is available at
# https://www.gnu.org/software/classpath/license.html.
#
# SPDX-License-Identifier: EPL-2.0 OR GPL-2.0 WITH Classpath-exception-2.0

export TCK_HOME=${WORKSPACE}

echo "TCK_HOME in jtatck.sh $TCK_HOME"
echo "ANT_HOME in jtatck.sh $ANT_HOME"
echo "PATH in jtatck.sh $PATH"
echo "ANT_OPTS in jtatck.sh $ANT_OPTS"

cd ${TCK_HOME}
ls -l ${WORKSPACE}/standalone-bundles/*.zip
ls -l ${WORKSPACE}/bundles/*.zip
ls -l ${WORKSPACE}/*.zip
if [ -f "${WORKSPACE}/standalone-bundles/jtatck-1.3_latest.zip" ];then
  echo "Using stashed bundle created as part of the build process"
else
  echo "Download and install JTA TCK Bundle ..."
  mkdir -p ${WORKSPACE}/standalone-bundles
  wget http://busgo1208.us.oracle.com/TCKS/tmpDirForLance/jtatck-1.3_28-May-2018.zip -O ${WORKSPACE}/standalone-bundles/jtatck-1.3_latest.zip
fi
unzip ${WORKSPACE}/standalone-bundles/jtatck-1.3_latest.zip -d ${TCK_HOME}

##### installRI.sh starts here #####
echo "Download and install GlassFish 5.0.1 ..."
if [ -z "${GF_BUNDLE_URL}" ]; then
  export GF_BUNDLE_URL="http://download.oracle.com/glassfish/5.0.1/nightly/latest-glassfish.zip"
fi
wget --progress=bar:force --no-cache $GF_BUNDLE_URL -O latest-glassfish.zip
unzip ${TCK_HOME}/latest-glassfish.zip -d ${TCK_HOME}

TS_HOME=${TCK_HOME}/jtatck
echo "TS_HOME $TS_HOME"

cd ${TS_HOME}/bin

sed -i "s#^webServerHome=.*#webServerHome=${TCK_HOME}/glassfish5/glassfish#g" ts.jte
sed -i "s#^report.dir=.*#report.dir=${TCK_HOME}/jtatckreport/jtatck#g" ts.jte
sed -i "s#^work.dir=.*#work.dir=${TCK_HOME}/jtatckwork/jtatck#g" ts.jte

mkdir -p ${TCK_HOME}/jtatckreport/jtatck
mkdir -p ${TCK_HOME}/jtatckwork/jtatck
export JT_REPORT_DIR=${TCK_HOME}/jtatckreport

ant config.vi
cd ${TS_HOME}/src/com/sun/ts/tests/
ant deploy
ant runclient
echo "Test run complete"

export HOST=`hostname -f`
echo "1 jtatck ${HOST}" > ${WORKSPACE}/args.txt
mkdir -p ${WORKSPACE}/results/junitreports/
${JAVA_HOME}/bin/java -Djunit.embed.sysout=true -jar ${WORKSPACE}/docker/JTReportParser/JTReportParser.jar ${WORKSPACE}/args.txt ${JT_REPORT_DIR} ${WORKSPACE}/results/junitreports/

tar zcvf ${WORKSPACE}/jtatck-results.tar.gz ${TCK_HOME}/jtatckreport ${TCK_HOME}/jtatckwork ${WORKSPACE}/results/junitreports/
