# Copyright 2014 Google Inc. All Rights Reserved.
#
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

# resource setting
TOTAL_MEMORY=$(free -m | grep Mem: | /usr/bin/awk '{print $2}')
CPU_CORES=$(grep -c processor /proc/cpuinfo) # virtual cores
MASTER_HEAPSIZE=$(( ${TOTAL_MEMORY} - 1024 ))
WORKER_HEAPSIZE=$(( ${TOTAL_MEMORY} - 1024 ))
WORKER_RESOURCE_MEMORY=$(( ${WORKER_HEAPSIZE} / ${CPU_CORES} ))
WORKER_TEMP_DIR=/hadoop/dfs/data/tajo

# Set up conf/tajo-site.xml
cat << EOF > ${TAJO_INSTALL_DIR}/conf/tajo-site.xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>tajo.rootdir</name>
    <value>${TAJO_ROOT_DIR}</value>
  </property>
  <property>
    <name>tajo.worker.start.cleanup</name>
    <value>true</value>
  </property>
  <property>
    <name>tajo.master.umbilical-rpc.address</name>
    <value>${MASTER_HOSTNAME}:26001</value>
  </property>
  <property>
    <name>tajo.master.client-rpc.address</name>
    <value>0.0.0.0:26002</value>
  </property>
  <property>
    <name>tajo.resource-tracker.rpc.address</name>
    <value>${MASTER_HOSTNAME}:26003</value>
  </property>
  <property>
    <name>tajo.catalog.client-rpc.address</name>
    <value>${MASTER_HOSTNAME}:26005</value>
  </property>
  <property>
    <name>tajo.worker.tmpdir.locations</name>
    <value>${WORKER_TEMP_DIR}</value>
  </property>
  <property>
    <name>tajo.task.resource.min.memory-mb</name>
    <value>${WORKER_RESOURCE_MEMORY}</value>
  </property>
  <property>
    <name>tajo.worker.resource.tajo.worker.resource.cpu-cores</name>
    <value>${CPU_CORES}</value>
  </property>
  <property>
    <name>tajo.worker.resource.disk.parallel-execution.num</name>
    <value>4</value>
  </property>
</configuration>
EOF

# Set up conf/catalog-site.xml
if [ ! -z $CATALOG_ID ] && [ ! -z $CATALOG_PW ] && [ ! -z $CATALOG_CLASS ] && [ ! -z $CATALOG_URI ]
then
cat << EOF > ${TAJO_INSTALL_DIR}/conf/catalog-site.xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>tajo.catalog.jdbc.connection.id</name>
    <value>${CATALOG_ID}</value>
  </property>
  <property>
    <name>tajo.catalog.jdbc.connection.password</name>
    <value>${CATALOG_PW}</value>
  </property>
  <property>
    <name>tajo.catalog.store.class</name>
    <value>${CATALOG_CLASS}</value>
  </property>
  <property>
    <name>tajo.catalog.jdbc.uri</name>
    <value>${CATALOG_URI}</value>
  </property>
</configuration>
EOF
fi

# Set up conf/workers
echo ${WORKERS[@]} | tr ' ' '\n' > ${TAJO_INSTALL_DIR}/conf/workers

# Set up conf/tajo-env.sh
cat << EOF >> ${TAJO_INSTALL_DIR}/conf/tajo-env.sh
export JAVA_HOME=${TAJO_JAVA_HOME}
export HADOOP_HOME=${HADOOP_INSTALL_DIR}
export TAJO_MASTER_HEAPSIZE=${MASTER_HEAPSIZE}
export TAJO_WORKER_HEAPSIZE=${WORKER_HEAPSIZE}
EOF

# Set up conf/storage-site.json
cat << EOF > ${TAJO_INSTALL_DIR}/conf/storage-site.json
{
  "storages": {
    "gs": {
      "handler": "org.apache.tajo.storage.FileTablespace"
    }
  }
}
