**0.13.4 - 18.01.2018**
- Fixed typo, pull request #139.

**0.13.3 - 10.02.2017**
- Bugfix: Fixed a bug which leads to infinite loop when using an include-path with an trailing backslash.

**0.13.2 - 20.11.2016**
- Bugfix: Command `Compile to file` did not works since 1.13.0-beta4

**0.13.1 - 07.10.2016**
- Fixed spelling bug.

**0.13.0 - 21.08.2016**
- New option: 'node-sass' execution timeout

**0.12.8 - 06.07.2016**
- Bugfix: Fixed cloning of `process.env`, which did not worked via `Object.create` any more

**0.12.7 - 31.05.2016**
- Bugfix: Prevent from compiling file when there is no active text editor ([issue #67](https://github.com/armin-pfaeffle/sass-autocompile/issues/67))

**0.12.6 - 31.03.2016**
- Bugfix: Compiled wrong file when option "auto save" is enabled and user switched tab ([issue #60](https://github.com/armin-pfaeffle/sass-autocompile/issues/60))

**0.12.5 - 13.03.2016**
- Documentation improved, based on [issue 57](https://github.com/armin-pfaeffle/sass-autocompile/issues/57)

**0.12.4 - 13.03.2016**
- Bugfix: "Compile on Save" parameter detection failed when invalid parameters were given ([issue #58](https://github.com/armin-pfaeffle/sass-autocompile/issues/58)

**0.12.3 - 23.02.2016**
- New option: "Compile Partials" ([issue 52](https://github.com/armin-pfaeffle/sass-autocompile/issues/52)
- Bugfix: Compilation started with "Only with first-line-comment" when having an ID definition in first line ([issue #53](https://github.com/armin-pfaeffle/sass-autocompile/issues/53)

**0.12.2 - 17.12.2015**
- Improved documentation
- Added additional parameter `includePaths` as alias for `includePath`

**0.12.1 - 16.12.2015**
- Fixed support for multiple include paths

**0.12.0 - 16.12.2015**
- Added new parameter: compileOnSave
- Loop-detection when using main parameter
- Improved inline parameter parsing performance
- Improved inline parser now supports arrays and objects
- Prepared for supporting multiple include paths

**0.11.0 - 12.11.2015**
- New feature: if node-sass command can not bet found, it's looked for in known paths. If node-sass command can be found there, the user is asked to set the path, so he does not have to manually set 'Path to node-sass command' option
- Improved inline parameter parsing
- Minor improvements

**0.10.8 - 03.11.2015**
- Bugfix: Invalid code path execution when no output style is available ([issue #31](https://github.com/armin-pfaeffle/sass-autocompile/issues/31))
- Bugfix: "Compile SASS" item in Tree View context menu was not working correctly
- Minor improvements

**0.10.7 - 21.10.2015**
- Bugfix: Could not open detailed output more than once because of missing "require" statement ([issue #30](https://github.com/armin-pfaeffle/sass-autocompile/issues/30))

**0.10.6 - 17.10.2015**
- Bugfix: Missing disposing of assigned events

**0.10.5 - 16.10.2015**
- Bugfix: Clicking on error message in panel did not open correct child file which contains the error ([issue #28](https://github.com/armin-pfaeffle/sass-autocompile/issues/28))

**0.10.4 - 14.10.2015**
- Bugfix: Package showed "Successfully Compiled" message, although no compilation has been executed ([issue #26](https://github.com/armin-pfaeffle/sass-autocompile/issues/26))
- Minor changes

**0.10.3 - 27.09.2015**
- Bugfix: Option "Compile files only with first-line-comment" did not work
- Bugfix: Cancelling saving unsaved file dialog leads to invalid internal state, so no compilation could be executed any more, only after restarting Atom

**0.10.2 - 24.09.2015**
- Improved and fixed direction compilation; now supporting SCSS and SASS
- Bugfix: Multiple parallel compilations were possible
- Bugfix: Wrong varialbe referencing
- Bugfix: "main" inline parameter was not handled correctly
- Bugfix: Fixed showing error
- Bugfix: Spaces between key and colon in inline paramters lead to an unhandled error
- Bugfix: Error in delete method leads to non-deleted files

**0.10.1 - 23.09.2015**
- Bugfix: "Cannot find module './File'"

**0.10.0 - 22.09.2015**
- Completely rewritten package
- Compile to file and direct compilation possible
- Compiling files with and without first line comment
- Separate compilations of compressed, comptact, nested and expanded output styles in one step
- Compilation stops on first error
- Improved parameter detection
- Warning for not using old parameters any more
- Improved panel usability
- Improved main menu
- Added item "Compile SASS" to Tree View context menu
- New shortcuts for file and direct compilation
- New option: Compile files ...
- New option: Directly jump to error
- New option: Show 'Compile SASS' item in Tree View context menu
- New options: Compile one SASS file to different output styles with different file names
- New option: Show additional compilation info
- New option: Show warning when using old paramters

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
