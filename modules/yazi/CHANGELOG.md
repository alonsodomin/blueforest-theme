# Change Log
All notable changes to the BlueForest theme for Yazi will be documented in this file.

Check [Keep a Changelog](http://keepachangelog.com/) for recommendations on how to structure this file.


## Unreleased

- The flavour is installed only when `blueforest-theme.yazi.enable` is true
- Initial release: the theme of Yazi, packaged as `blueforest-yazi-theme`. It
  is a flavour, the format Yazi reads, and it carries the colours of the code
  preview as well
- The Home Manager module installs the flavour in the directory Yazi reads the
  flavours from, and it selects it in the theme of the user. It writes nothing
  when Yazi is not enabled
- The theme depends on the theme of bat: the package of the theme of Yazi
  carries the package of the theme of bat, and the flavour links to the
  TextMate theme of bat for the colours of the code preview, instead of
  carrying a copy of it
- The overlay of the application adds the package of the theme of bat as well,
  next to the package of the theme of Yazi
