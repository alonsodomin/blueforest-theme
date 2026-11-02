# Change Log

All notable changes to the BlueForest prompt for sbt will be documented in this file.

Check [Keep a Changelog](http://keepachangelog.com/) for recommendations on how to structure this file.


## Unreleased

- The BlueForest prompt shows the status of the repository, the way the
  Starship preset of the repository does: the number of files that are staged,
  modified, deleted, renamed, untracked or in conflict, and the number of
  commits that are not pushed yet. The branch keeps the colours of the Git
  segment of Starship, whatever the state of the working tree is
- Initial version: the BlueForest prompt for sbt, packaged as
  `blueforest-sbt-prompt`. It installs the `sbt-prompt` plugin and selects its
  `BlueforestTheme`, both defined upstream at
  <https://github.com/alonsodomin/sbt-prompt>
