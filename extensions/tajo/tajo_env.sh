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

# This file contains environment-variable overrides to be used in conjunction
# with bdutil_env.sh in order to deploy a Hadoop cluster with HBase installed
# and configured.
# Usage: ./bdutil deploy extensions/tajo/tajo_env.sh.

# URIs of tarball to install. [Required]
TAJO_TARBALL_URI='gs://tajo-test_ys/tajo/tajo-0.10.0.tar.gz'

# Base dir of tajo. [Required]
TAJO_ROOT_DIR='gs://tajo-test_ys/tajo'

# For catalog store. default is derby.
CATALOG_ID=''
CATALOG_PW=''
CATALOG_CLASS=''
CATALOG_URI=''

# For tajo third party lib.
EXT_LIB=''

# Directory on each VM in which to install tajo.
TAJO_INSTALL_DIR='/home/hadoop/tajo-install'

# Sets environment variables for Hadoop 2.x deployment

GCS_CACHE_CLEANER_LOGGER='INFO,RFA'

# URI of Hadoop tarball to be deployed. Must begin with gs:// or http(s)://
# Use 'gsutil ls gs://hadoop-dist/hadoop-*.tar.gz' to list Google supplied options
HADOOP_TARBALL_URI="gs://hadoop-dist/hadoop-2.7.1.tar.gz"

# Directory holding config files and scripts for Hadoop
HADOOP_CONF_DIR="${HADOOP_INSTALL_DIR}/etc/hadoop"

# Fraction of worker memory to be used for YARN containers
NODEMANAGER_MEMORY_FRACTION=0.8

# Decimal number controlling the size of map containers in memory and virtual
# cores. Since by default Hadoop only supports memory based container
# allocation, each map task will be given a container with roughly
# (CORES_PER_MAP_TASK / <total-cores-on-node>) share of the memory available to
# the NodeManager for containers. Thus an n1-standard-4 with CORES_PER_MAP_TASK
# set to 2 would be able to host 4 / 2 = 2 map containers (and no other
# containers). For more details see the script 'libexec/configure-mrv2-mem.py'.
CORES_PER_MAP_TASK=1.0

# Decimal number controlling the size of reduce containers in memory and virtual
# cores. See CORES_PER_MAP_TASK for more details.
CORES_PER_REDUCE_TASK=2.0

# Decimal number controlling the size of application master containers in memory
# and virtual cores. See CORES_PER_MAP_TASK for more details.
CORES_PER_APP_MASTER=2.0

# Connector with Hadoop AbstractFileSystem implemenation for YARN
GCS_CONNECTOR_JAR='https://storage.googleapis.com/hadoop-lib/gcs/gcs-connector-1.4.1-hadoop2.jar'

BIGQUERY_CONNECTOR_JAR='https://storage.googleapis.com/hadoop-lib/bigquery/bigquery-connector-0.7.1-hadoop2.jar'


HDFS_DATA_DIRS_PERM='700'

# 8088 for YARN, 50070 for HDFS.
MASTER_UI_PORTS=('8088' '50070')

# Use Hadoop 2 specific configuration templates.
if [[ -n "${BDUTIL_DIR}" ]]; then
  UPLOAD_FILES=($(find ${BDUTIL_DIR}/conf/hadoop2 -name '*template.xml'))
  UPLOAD_FILES+=("${BDUTIL_DIR}/libexec/hadoop_helpers.sh")
  UPLOAD_FILES+=("${BDUTIL_DIR}/libexec/configure_mrv2_mem.py")
fi

COMMAND_GROUPS+=(
  "install_tajo:
     extensions/tajo/install_tajo.sh
  "
  "configure_tajo:
     extensions/tajo/configure_tajo.sh
  "
  "start_tajo:
     extensions/tajo/start_tajo.sh
  "
)

# Installation of tajo on master and workers; then start_tajo only on master.
COMMAND_STEPS=(
  "deploy-ssh-master-setup,*"
  'deploy-core-setup,deploy-core-setup'
  "*,deploy-ssh-worker-setup"
  'install_tajo,install_tajo'
  'configure_tajo,configure_tajo'
  'start_tajo,*'
)
