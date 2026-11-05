# Change Log
All notable changes to the BlueForest theme for MkDocs will be documented in this file.

Check [Keep a Changelog](http://keepachangelog.com/) for recommendations on how to structure this file.


## 0.4.0 - [05-11-2026]

- The stylesheet has a light variant now: the light scheme of Material gets the
  colours of the light palette of the repository
- Initial release: the stylesheet of the code blocks of Material for MkDocs in
  the dark scheme, packaged as `blueforest-mkdocs-theme`
- The flake module installs the stylesheet in the documentation sources through
  the `mkdocs-flake` pre-build hook, and it leaves the hook of the project alone
- The numbers of the code blocks are painted with the colour of the numbers,
  which Material paints with no class of its own
