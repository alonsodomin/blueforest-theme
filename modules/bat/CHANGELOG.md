# Change Log
All notable changes to the BlueForest theme for bat will be documented in this file.

Check [Keep a Changelog](http://keepachangelog.com/) for recommendations on how to structure this file.


## Unreleased

- Initial release: the theme of bat, packaged as `blueforest-bat-theme`
- The theme is installed in the configuration directory of bat, which is where
  bat reads the themes from, and the cache of bat is rebuilt, so that the
  theme is picked up without further work
- The keys of a JSON document are painted with the colour of the types, like
  the theme of VS Code does, and the strings keep the colour of the strings
- The shell scopes are painted the way the other applications of the repository
  paint them: the command is a function, the arguments are parameters, the
  options are operators, and the brackets are punctuation
