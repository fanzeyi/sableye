#!/bin/bash

watchman -j <<-EOT
["trigger", "./templates", {
   "name": "build-templates",
   "expression": ["imatch","**/*.html", "wholename"],
   "command": [
       "osascript",
       "-e",
       "tell application \"iTerm\" to tell current session of first tab of current window to write text \"C.rec\""
   ],
   "append_files": false,
   "stdin": "NAME_PER_LINE"
}]
EOT

watchman -j <<-EOT
["trigger", "./lib", {
   "name": "compile-and-reload",
   "expression": ["imatch","**/*.ex", "wholename"],
   "command": [
       "osascript",
       "-e",
       "tell application \"iTerm\" to tell current session of first tab of current window to write text \"C.rec\""
   ],
   "append_files": false,
   "stdin": "NAME_PER_LINE"
}]
EOT


