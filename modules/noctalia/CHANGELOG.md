# Change Log
All notable changes to the BlueForest theme for Noctalia will be documented in this file.

Check [Keep a Changelog](http://keepachangelog.com/) for recommendations on how to structure this file.


## 0.4.0 - [05-11-2026]

- The palette carries a light variant as well, which is a palette of
  its own and not a copy of the dark one
- The package carries the palette in the format 2 of the community
  palette registry as well, under the name `blueforest-v2.json`, and
  the file of the format 2 is generated from the canonical one
- The palette is installed only when `blueforest-theme.noctalia.enable` is
  true
- Initial release: the palette of Noctalia, packaged as
  `blueforest-noctalia-theme`
- The Home Manager module installs the palette in the directory Noctalia reads
  the palettes from, selects it in a file of its own, and it writes nothing
  when Noctalia is not enabled
