#!/bin/bash

# ---------------------------------------------------------------------------
# See the NOTICE file distributed with this work for additional
# information regarding copyright ownership.
#
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 2.1 of
# the License, or (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this software; if not, write to the Free
# Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA, or see the FSF site: http://www.fsf.org.
# ---------------------------------------------------------------------------

# Collect the modules.
modules=()
currentFolderName=${PWD##*/}
for module in *; do
  # Skip files and symbolic links.
  # Use only the folders that starts with '<currentFolderName>-'
  if [[ -d $module && ! -L $module && $module == $currentFolderName-* ]]; then
    modules+=("$module")
  fi
done

function callForEachModule() {
  for module in "${modules[@]}"; do
    $1 "${module}"
  done
}

function set_version() {
  cd $1

  echo -e "\033[0;32m* Set version ${VERSION} in ${1}\033[0m"
  mvn versions:set -DgenerateBackupPoms=false -DnewVersion=$VERSION

  cd ..
}

function set_version_all() {
  echo              "*****************************"
  echo -e "\033[0;32m    Set version ${VERSION} in all pom files\033[0m"
  echo              "*****************************"

  callForEachModule set_version

  update_documentation
}

function set_parent_version() {
  cd $1

  echo -e "\033[0;32m* Set parent version ${PARENT_VERSION} in ${1}\033[0m"
  mvn versions:update-parent -DgenerateBackupPoms=false -DparentVersion=[$PARENT_VERSION]

  cd ..
}

function set_parent_version_all() {
  echo              "*****************************"
  echo -e "\033[0;32m    Set parent version ${PARENT_VERSION} in all pom files\033[0m"
  echo              "*****************************"

  callForEachModule set_parent_version
}

function commit_all() {
  echo              "*****************************"
  echo -e "\033[0;32m    Commit new version\033[0m"
  echo              "*****************************"

  git commit -a -m "[release] Set version" || true
}

function tag_all() {
  echo              "*****************************"
  echo -e "\033[0;32m    Create tag for new version\033[0m"
  echo              "*****************************"

  git tag -m "Tagging ${currentFolderName}-${VERSION}" ${currentFolderName}-${VERSION}
}

function deploy_pom() {
  cd $1

  echo -e "\033[0;32m* Deploy ${1} ${VERSION}\033[0m"
  mvn deploy -DperformRelease=true -Prelease-parent

  cd ..
}

function deploy_all() {
  echo              "*****************************"
  echo -e "\033[0;32m    Deploy all pom files\033[0m"
  echo              "*****************************"

  callForEachModule deploy_pom
}

function update_documentation() {
  echo              "*****************************"
  echo -e "\033[0;32m    Update documentation\033[0m"
  echo              "*****************************"

  sed -i -e "s/$PREVIOUS_VERSION/$VERSION/g" README.md
}

# Check version to release
if [[ -z $VERSION ]]
then
  cd "${modules[0]}"
  current_version=$(mvn -q -Dexec.executable="echo" -Dexec.args='${project.version}' --non-recursive exec:exec)
  cd ..
  n=${current_version##*[!0-9]}
  p=${current_version%%$n}
  next_version=$p$((n+1))

  echo -e "Which version are you releasing?"
  read -e -p "> ($next_version) " tmp
  if [[ $tmp ]]
  then
    next_version=$tmp
  fi

  export PREVIOUS_VERSION=$current_version
  export VERSION=$next_version

  echo -n -e "\033[0m"
fi

# Check parent version to update
if [[ -z $PARENT_VERSION ]]
then
  cd "${modules[0]}"
  parent_version=$(mvn -q -Dexec.executable="echo" -Dexec.args='${project.parent.version}' --non-recursive exec:exec)
  cd ..

  echo -e "Do you want to change the parent version?"
  read -e -p "> ($parent_version) " tmp
  if [[ $tmp ]]
  then
    export PARENT_VERSION=$tmp
  fi

  echo -n -e "\033[0m"
fi

set -e

set_version_all
if [[ ! -z $PARENT_VERSION ]]; then
  set_parent_version_all
fi
commit_all
tag_all
deploy_all

echo -e "\033[0;32m Push changes and tag\033[0"
git push --tags
git push
