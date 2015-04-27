# sass-autocompile package

Automatically compiles SASS files on save.

---

Inspired by and based on [less-autocompile](https://atom.io/packages/less-autocompile) package, written by [lohek](https://atom.io/users/lohek), I have created a counterpart for [SASS](http://sass-lang.com/). This package automatically compiles your SASS file (file ending: `.scss`) when you save it.



## Requirements

At the moment, you can only use this package when you install [node.js](http://nodejs.org/) and [node-sass](https://www.npmjs.com/package/node-sass) on you system. It's important that you install node-sass globally (command: `npm install node-sass -g`), so it's possible to access it via CLI.

The reason why *sass-autocompile* needs that is because node-sass is not compatible with atom shell in the current version (2.0.1), so it cannot be added as dependency. Probably that will change later, so you won't have to install node.js and node-sass additionally ‒ I put it to the roadmap.



## Usage

**Important: ** *Install node.js and node-sass before, see [requirements](#requirements).*

Basically you enable auto-compile on save in two steps:

1. Add `.scss` as file extension to your SASS file
2. Add at least `// out: ../css/main.css` to the **first line** of your SASS file

But to enable advanced features have a look at the complete list of [parameters](#parameters). The [examples](#examples) give you a short demonstration about using them.

Beside the parameters you can set [plugin options](#options) which are used as general options for auto-compiling. **Important**: since version 0.5 parameters in SASS files override the general options ‒ so you can enable `Compress CSS` in options, but disable this feature for a special project by setting `compress: false` in your SASS file parameters.

After saving a SASS file, you should see a notification or a panel at the bottom of the editor, depending on your settings, showing you an error or success message. If you use *panel notification* ([see options](#options) -> `Notifications`) , you have the possibility to access the output CSS file by clicking on the compilation message. If compiliation fails, you can even jump to error position in the corresponding SCSS file where error occured.


### Parameters

Add following parameters in *comma-separated* way to the **first line** of your SASS file (file extension: `.scss`). See [examples](#examples) for demonstration, especially for `main` parameter:
```js
// path of target CSS file
out: main.css

// if true CSS file is compressed
compress: true / false

// path to your main SASS file to be compiled
// see http://sass-guidelin.es/#main-file
main: ../main-scss.scss

// creates source map file if a filename is given or if true source map filename
// is automatically set as css filename extended with ".map" [*]
sourceMap: true / false / main.css.map

// if true source map is embedded as data URI [*]
sourceMapEmbed: true / false

// if true the contents are included to the source map information [*]
sourceMapContents: true / false

// if true additional debugging information is added to the output file as CSS
// comments, but only if CSS is not compressed [*]
sourceComments: true / false

// path to look for imported files [*]
includePath: ../my-framework/scss/
```
 (*) For further information have a look at the [node-sass documentation](https://github.com/sass/node-sass).


### Examples

When you add the `out` parameter your SASS file is compiled to `main.css` in the relative path `../css/`.
```
// out: ../css/main.css
```

To additionally compress the output you have to add `compress: true`, or you enable option *Compress CSS*:
```
// out: ../css/main.css, compress: true
```

If you use `@import` command in SASS, you should define the `main` parameter in the *child files*. Imagine you have the following structure:
```
main.scss       // main file which imports colors and layout files
colors.scss     // contains color definitions
layout.scss     // contains layout definitions
```

Add the following comment to `main.scss` to enabled auto compilation on save.
```
// out: ../css/main.css, compress: true
```

... and add this to `colors.scss` and `layout.scss` to enable auto compilation on saving each of this two *child files*.
```
// main: main.scss
```
The special about this parameter is, that when you save a child file, the `main.scss` is compiled, not the child file itself. So you can structure your SASS files, modify them and after saving, everything is compiled correctly, not only the saved file.



## Options

#### **Enabled**
You can use this option to disable auto compiling SASS file on save. This is especially useful when you migrate from CSS or LESS to SASS, having some errors in the SASS files and don't want to see a error message on each save.  
**Shortcut for toggling auto-compile**: `ctrl-alt-shift-s` / `ctrl-cmd-shift-s`  
*__Default__: true*


#### **Compress CSS**
If enabled this option ensures that the output is compressed, even if you do **not** use the `compress` parameter.  
*__Default__: false*


#### **Build source map**
If enabled a [source map](http://www.html5rocks.com/en/tutorials/developertools/sourcemaps/) is generated. Filename is automatically obtained by taking the output CSS filename and appending `.map`, e.g. `output.css.map`.  
*__Default__: false*


#### **Embed source map**
If enabled source map (see option [Build source map](#build-source-map)) is embedded as a data URI.  
*__Default__: false*


#### **Include contents in source map information**
If enabled contents are included in source map information.  
*__Default__: false*


#### **Include additional debugging information in the output CSS file**
If enabled additional debugging information are added to the output file as CSS comments. If CSS is compressed this feature is disabled by SASS compiler.  
*__Default__: false*


#### **Include path**
Path to look for imported files (`@import` declarations).  
*__Default__: ''*


#### **Notifications**
This options allows you to decide which feedback you want to see when SASS files are compiled: notification and/or panel.  
**Panel**: The panel is shown at the bottom of the editor. When starting the compilation it's only a small header with a throbber. After compiliation a success or error message is shown with reference to the CSS file, or on error the SCSS file. By clicking on the message you can access the CSS or error file.  
**Notification**: The default atom notifications are used for output.  
*__Default__: Panel*


#### **Automatically hide panel on ...**
Select on which event the panel should automatically disappear. If you want to hide the panel via shortcut, you can use `ctrl-alt-shift-h` / `ctrl-cmd-shift-h`.  
*__Default__: Success*


#### **Panel-auto-hide delay**
Delay after which panel is automatically hidden.
*__Default__: 3000*


#### **Automatically hide notifications on ...**
Decide when you want the notifications to automatically hide. Else you have to close every notification manually.  
*__Default__: Info, Success*


#### **Show 'Start Compiling' Notification**
If enabled and you added the notification option in `Notifications`, you will see an info-message when compile process starts.  
*__Default__: false*



## Predefined shortcuts

#### `ctrl-alt-shift-s` / `ctrl-cmd-shift-s`

Toggles the *sass-autocompile* functionality. If auto-compile functionality is en-/disabled a notification is shown.


#### `ctrl-alt-shift-h` / `ctrl-cmd-shift-h`

Hides the panel if visible.



## Issues, questions & feedback

[Please post issues on GitHub](https://github.com/armin-pfaeffle/sass-autocompile/issues).

For other concerns like questions or feeback [have a look at the discussion thread on atom.io](https://discuss.atom.io/t/issues-questions-feedback-about-sass-autocompile/15233).



## Roadmap

- Add node-sass as dependency, so we do not need extra node.js and node-sass installation



## Changelog

**0.6.2 - 27.04.2015**
- Bugfix: Fixed issue [#5](https://github.com/armin-pfaeffle/sass-autocompile/issues/5)

**0.6.1 - 15.04.2015**
- Bugfix: Issue #4 was not fixed with 0.6.0; Added Option for absolute path to node-sass command
- Optimized option requests
- Optimized option preparation for more performance

**0.6.0 - 12.04.2015**
- Bugfix: Starting Atom via Dock on Mac OS X leads to "command not found" error"

**0.5.0 - 09.04.2015**
- **Changed behaviour**: specifying parameters in SCSS file overrides settings and not vice versa
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
- Fixed bug that opens a SCSS file two times when clicking on panel error message
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
