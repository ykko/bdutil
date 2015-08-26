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
TAJO_TARBALL_URI=''

# Base dir of tajo. [Required]
TAJO_ROOT_DIR=''

# For catalog store. default is derby.
CATALOG_ID=''
CATALOG_PW=''
CATALOG_CLASS=''
CATALOG_URI=''

# For tajo third party lib.
EXT_LIB=''

# Directory on each VM in which to install tajo.
TAJO_INSTALL_DIR='/home/hadoop/tajo-install'

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
COMMAND_STEPS+=(
  'install_tajo,install_tajo'
  'configure_tajo,configure_tajo'
  'start_tajo,*'
)
