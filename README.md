Provide various parent pom.xml for contrib extensions

# Versions

Version is <branch>-<buildnumber> as in 6.4-3 which is the 3rd version of the parent pom to use for contrib extension which support XWiki 6.4 version and more.

# Release

The Maven Release Plugin cannot be used for these pom.xml because one of the goal is to make sure release setup is a clean slate when you use them as parent.

* Go to the right branch
* ./release.sh
* Go to http://nexus.xwiki.org, close and release the corresponding staging repository
