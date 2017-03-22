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

  set_version parent-commons
  set_version parent-rendering
  set_version parent-platform

  update_documentation
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

  git tag -m "Tagging ${parent-$VERSION}" parent-${VERSION}
}

function deploy_pom() {
  cd $1

  echo -e "\033[0;32m* Deploy ${1} ${VERSION}\033[0m"
  mvn deploy -Dxwiki.enforcer.skip=true -Prelease-parent

  cd ..
}

function deploy_all() {
  echo              "*****************************"
  echo -e "\033[0;32m    Deploy all pom files\033[0m"
  echo              "*****************************"

  deploy_pom parent-commons
  deploy_pom parent-rendering
  deploy_pom parent-platform
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
  cd parent-commons
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

set -e

set_version_all
commit_all
tag_all
deploy_all

echo -e "\033[0;32m Push changes and tag\033[0"
git push --tags
git push

