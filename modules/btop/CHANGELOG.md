# Change Log
All notable changes to the BlueForest theme for btop will be documented in this file.

Check [Keep a Changelog](http://keepachangelog.com/) for recommendations on how to structure this file.


## 0.4.0 - [05-11-2026]

- The theme is installed only when `blueforest-theme.btop.enable` is true. A
  configuration that enables the theme and the template of the
  community catalogue of Noctalia for btop fails to evaluate
- Initial release: the theme of btop, packaged as `blueforest-btop-theme`
- The Home Manager module installs the theme in the directory btop reads the
  themes from, selects it in the configuration of btop, and it writes nothing
  when btop is not enabled
