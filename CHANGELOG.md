**0.9.1 - 17.09.2015**
- Modified option: Killed darwin-only to allow any OS (eg Ubuntu – which has process.platform "linux") to enjoy the "Path to 'node-sass'" option.

**0.9.0 - 31.08.2015**
- New option: Indent type / as inline parameter: indentType
- New option: Indent width / as inline parameter: indentWidth
- New option: Linefeed / as inline parameter: linefeed
- New option: Precision / as inline parameter: precision
- New option: Filename to custom importer / as inline parameter: importer
- New option: Filename to custom functions / as inline parameter: functions

**0.8.0 - 31.08.2015**
- New option: Output style (thanks to [reardestani](https://github.com/reardestani))
- Improved menu items with output style selection
- Option 'Compress CSS' removed because of new option output style
- Minor improvements

**0.7.5 - 30.07.2015**
- Fixed includePath parameter option, so it works correctly now

**0.7.4 - 30.07.2015**
- Added support for `.sass` file extension (thanks to [Chris Kjærsig](https://github.com/cmk2179) for this idea!)

**0.7.3 - 24.07.2015**
- Bugfix: Fixed issue [#10](https://github.com/armin-pfaeffle/sass-autocompile/issues/10)

**0.7.2 - 15.07.2015**
- Bugfix: Fixed issue [#9](https://github.com/armin-pfaeffle/sass-autocompile/issues/9)

**0.7.1 - 15.06.2015**
- Bugfix: Fixed issue [#8](https://github.com/armin-pfaeffle/sass-autocompile/issues/8)
- Fixed and optimized error recognition

**0.7.0 - 20.05.2015**
- New features: node-sass command output can be opened in a new tab
- New option: open node-sass command output automatically after compilation
- Completed missing documentation

**0.6.5 - 18.05.2015**
- Bugfix: Fixed issue [#7](https://github.com/armin-pfaeffle/sass-autocompile/issues/7)

**0.6.4 - 12.05.2015**
- Bugfix: Finally fixed issue [#4](https://github.com/armin-pfaeffle/sass-autocompile/issues/4)
- Bugfix: Start Compiling notification was visible in panel although option was disabled

**0.6.3 - 05.05.2015**
- Bugfix: Fixed issue [#6](https://github.com/armin-pfaeffle/sass-autocompile/issues/6)

**0.6.2 - 27.04.2015**
- Bugfix: Fixed issue [#5](https://github.com/armin-pfaeffle/sass-autocompile/issues/5)

**0.6.1 - 15.04.2015**
- Bugfix: Issue [#4](https://github.com/armin-pfaeffle/sass-autocompile/issues/4) was not fixed with 0.6.0; Added Option for absolute path to node-sass command
- Optimized option requests
- Optimized option preparation for more performance

**0.6.0 - 12.04.2015**
- Bugfix: Starting Atom via Dock on Mac OS X leads to "command not found" error"

**0.5.0 - 09.04.2015**
- **Changed behaviour**: specifying parameters in SASS file overrides settings and not vice versa
- File extension detection (.scss) is now case **insensitive**
- Code refactoring
- Bugfix: Toggling option "Compress CSS" toggled enabled option
- Bugifx: Auto-hiding panel on error did not work correctly
- Bugfix: Close button on panel did not instantly hide panel
- Bugfix: Wrong title for option 'sourceComments'
- Updated Readme

**0.4.0 - 18.03.2015**
- Added options and corresponding parameters for node-sass call (sourceMap, sourceMapEmbed, sourceMapContents, sourceComments, includePath)
- Bugfix: spaces in filenames leads to "File does not exist" errors

**0.3.2 - 10.03.2015**
- Fixed bug that opens a SASS file two times when clicking on panel error message
- Fixed issue [#2](https://github.com/armin-pfaeffle/sass-autocompile/issues/2)

**0.3.1 - 08.03.2015**
- Added notification message on toggling auto-compile

**0.3.0 - 07.03.2015**
- Extended notifications
- Added panel with "Go to CSS file/error position" functionality
- Added options for better customization

**0.2.0 - 04.03.2015**
- Added keymap with ctrl-alt-shift-s shortcut for toggling auto compile
- Added option "enabled" for en-disabling auto compile
- Added option "always compress"

**0.1.0 - 03.03.2015**
- Initial version
