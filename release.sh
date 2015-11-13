function set_version() {
  cd $1

  echo -e "\033[0;32m* Set version ${VERSION} in ${1}\033[0m"
  mvn versions:set -DnewVersion=$VERSION
}

function set_version_all() {
  echo              "*****************************"
  echo -e "\033[1;32m    Set version ${VERSION} in all pom files\033[0m"
  echo              "*****************************"

  set_version parent-commons
  set_version parent-rendering
  set_version parent-platform
}

function commit_all() {
  echo              "*****************************"
  echo -e "\033[1;32m    Commit new version\033[0m"
  echo              "*****************************"

  mvn commit -a -m "[release] Set version"
}

function tag_all() {
  echo              "*****************************"
  echo -e "\033[1;32m    Create tag for new version\033[0m"
  echo              "*****************************"

  git tag -m "Tagging ${parent-$VERSION}" parent-${VERSION}
}

function deploy_pom() {
  cd $1

  echo -e "\033[0;32m* Deploy version ${1} ${VERSION}\033[0m"
  mvn deploy  
}

function deploy_all() {
  echo              "*****************************"
  echo -e "\033[1;32m    Deploy all pom files\033[0m"
  echo              "*****************************"

  deploy_pom parent-commons
  deploy_pom parent-rendering
  deploy_pom parent-platform
}

# Check version to release
if [[ -z $VERSION ]]
then
  echo -e "Which version are you releasing?\033[0;32m"
  read -e -p "> " VERSION
  echo -n -e "\033[0m"
  export VERSION=$VERSION
fi

set_version_all
commit_all
tag_all
deploy_all

