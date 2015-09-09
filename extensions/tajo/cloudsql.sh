# Copyright 2014 Google Inc. All Rights Reserved.  #
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS-IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o nounset
set -o errexit

# Set up conf/catalog-site.xml
if [ ! -z $CLOUD_SQL_INSTANCE_ID ]
then

  # Getting public IP
  EXTERNAL_IP=`gcloud compute instances describe ${MASTER_HOSTNAME} --zone ${GCE_ZONE} --format text | grep natIP | awk '{print $2}'`
  CLOUD_SQL_INSTANCE_IP=`gcloud sql instances describe ${CLOUD_SQL_INSTANCE_ID} --format text | grep ipAddress | awk '{print $2}'`

  if [ -z $CLOUD_SQL_INSTANCE_IP ]
  then
    # Create new cloud sql instance.
    gcloud sql instances create ${CLOUD_SQL_INSTANCE_ID} --assign-ip --tier "D0"
    gcloud sql instances set-root-password ${CLOUD_SQL_INSTANCE_ID} --password ${CLOUD_SQL_CON_PW}
    CLOUD_SQL_INSTANCE_IP=`gcloud sql instances describe ${CLOUD_SQL_INSTANCE_ID} --format text | grep ipAddress | awk '{print $2}'`
  fi

CLOUD_SQL_CON_URI="jdbc:mysql://${CLOUD_SQL_INSTANCE_IP}:3306/${CLOUD_SQL_CON_DB}?createDatabaseIfNotExist=true"
# Setting authorized network
gcloud sql instances patch ${CLOUD_SQL_INSTANCE_ID} --authorized-networks ${EXTERNAL_IP}

cat << EOF > ${TAJO_INSTALL_DIR}/conf/catalog-site.xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>tajo.catalog.jdbc.connection.id</name>
    <value>${CLOUD_SQL_CON_ID}</value>
  </property>
  <property>
    <name>tajo.catalog.jdbc.connection.password</name>
    <value>${CLOUD_SQL_CON_PW}</value>
  </property>
  <property>
    <name>tajo.catalog.store.class</name>
    <value>org.apache.tajo.catalog.store.MySQLStore</value>
  </property>
  <property>
    <name>tajo.catalog.jdbc.uri</name>
    <value>${CLOUD_SQL_CON_URI}</value>
  </property>
</configuration>
EOF

fi
