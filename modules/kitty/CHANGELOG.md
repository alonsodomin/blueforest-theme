# Change Log
All notable changes to the BlueForest theme for kitty will be documented in this file.

Check [Keep a Changelog](http://keepachangelog.com/) for recommendations on how to structure this file.


## Unreleased

- The theme has a light variant now, `blueforest-light`, and the switch of
  the variant selects the one that is installed
- The theme is installed only when `blueforest-theme.kitty.enable` is true. A
  configuration that enables the theme and the template of the
  community catalogue of Noctalia for kitty fails to evaluate
- Initial release: the theme of kitty, packaged as `blueforest-kitty-theme`
- The Home Manager module installs the theme in the directory kitty reads the
  themes from, selects it in the configuration of kitty, and it writes nothing
  when kitty is not enabled
