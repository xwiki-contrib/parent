Provide various parent pom.xml for contrib extensions.

Extensions are automatically release on http://nexus.xwiki.org if your user have the release right.

# Example

For extensions having xwiki-platform dependencies:

```xml
  <parent>
    <groupId>org.xwiki.contrib</groupId>
    <artifactId>parent-platform</artifactId>
    <version>7.4-6</version>
  </parent>
```

For extensions having xwiki-rendering and xwiki-commons dependencies:

```xml
  <parent>
    <groupId>org.xwiki.contrib</groupId>
    <artifactId>parent-rendering</artifactId>
    <version>7.4-6</version>
  </parent>
```

For extensions having xwiki-commons dependencies only:

```xml
  <parent>
    <groupId>org.xwiki.contrib</groupId>
    <artifactId>parent-commons</artifactId>
    <version>7.4-6</version>
  </parent>
```

# Versions

Version is \<branch>-\<buildnumber> as in 6.4-3 which is the 3rd version of the parent pom to use for contrib extension which support XWiki 6.4 version and more.

# Release of a new parent pom

The Maven Release Plugin cannot be used for these pom.xml because one of the goal is to make sure release setup is a clean slate when you use them as parent.

* Go to the right branch
* ./release.sh
* Go to http://nexus.xwiki.org, close and release the corresponding staging repository
