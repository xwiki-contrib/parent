Provide various parent pom.xml for contrib extensions

# Example

For extensions having xwiki-platform dependencies:

  <parent>
    <groupId>org.xwiki.contrib</groupId>
    <artifactId>parent-platform</artifactId>
    <version>7.4</version>
  </parent>

For extensions having xwiki-commons dependencies only:

  <parent>
    <groupId>org.xwiki.contrib</groupId>
    <artifactId>parent-commons</artifactId>
    <version>7.4</version>
  </parent>

# Versions

Version is \<branch>-\<buildnumber> as in 6.4-3 which is the 3rd version of the parent pom to use for contrib extension which support XWiki 6.4 version and more.

# Release

The Maven Release Plugin cannot be used for these pom.xml because one of the goal is to make sure release setup is a clean slate when you use them as parent.

* Go to the right branch
* ./release.sh
* Go to http://nexus.xwiki.org, close and release the corresponding staging repository

# TODO

Setup org.sonatype.plugins:nexus-staging-maven-plugin plugin for the Nexus validation step to be done automatically.
