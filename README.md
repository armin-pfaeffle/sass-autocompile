# sass-autocompile package

Automatically compiles SASS files on save.

---

Inspired by [less-autocompile](https://atom.io/packages/less-autocompile) package, written by [lohek](https://atom.io/users/lohek), I have created a counterpart for SASS. This package automatically compiles your SASS file (file ending: `.scss`) when you save it.


## Requirements

At the moment, you can only use this package when you install [node.js](http://nodejs.org/) and [node-sass](https://www.npmjs.com/package/node-sass) on you system. It's important that you install node-sass globally `npm install node-sass -g`, so it's possible to access it via CLI.

The reason why sass-autocompile needs that is because node-sass is not compatible with atom shell in the current version (2.0.1), so it cannot be added as dependency. Probably that will change later, so you won't have to install node.js and node-sass additionally ‒ I have put it  the roadmap.


## Usage

**Important: ** *Install node.js and node-sass before, see [requirements](#requirements).*

To use auto-compile functionality you only have to add the following parameters on the **first line** of your SASS file ‒ for correct usage, see examples above.
```
out (string):  path of CSS file to create
compress (bool): compress CSS file
main (string): path to your main LESS file to be compiled
```
If you use panel notification, you have the possibility to access the output CSS file by clicking on the compilation message. If compiliation fails, you can jump to position in the SCSS file where error occured

### Examples
When you add th `out` parameter your SASS file is compiled to `main.css` in the relative path `../css/`.
```
// out: ../css/main.css
```

To additionally compress the output you have to add `compress: true`, or you enable option [always compress](#always-compress):
```
// out: ../css/main.css, compress: true
```

If you use `@import` command in SASS, you should define the `main` parameter in the *child files*. Imagine you have the following file structure:
```
index.scss      // main file which imports colors and layout files
colors.scss     // contains color definitions
layout.scss     // contains layout definitions
```

Add the following comment to `main.scss` to enabled auto compilation on saving `index.scss`.
```
// out: ../css/main.css, compress: true
```

... and add this to `colors.scss` and `layout.scss` to enable auto compilation on saving each of this two *child* files.
```
// main: index.scss
```
The special about this parameter is, that when you save a child file, the `index.scss` is compiled, not the child file itself. So you can structure you SASS files, modify them and after saving, everything is compiled correctly.


## Options

`Enabled` *Default: true*  
You can use this option to disable auto compiling SASS file on save. This is especially useful when you migrate from CSS or LESS to SASS, having some errors in the SASS files and don't want to see a error message on each save.  
**Predefined shortcut**: `ctrl-alt-shift-s`

`Always compress`  *Default: false*  
If enabled this option ensures that the output is compressed, even if you do **not** use the `compress` paramaeter in the first line.

`Notifications` *Default: Panel*  
This options allows you to decide which feedback you want to see when SASS files are compiled: notification and/or panel.  
**Panel**: The panel is shown at the bottom of the editor. When starting the compilation it's only a small header with a throbber. After compiliation a success or error message is shown with reference to the CSS file, or on error the SCSS file. By clicking on the message you can access the CSS or error file.  
**Notification**: The default atom notifications are used for output.

`Automatically hide panel on ...` *Default: Success*  
Select on which event the panel should automatically disappear.

`Panel-auto-hide delay` *Default: 3000*  
Delay after which panel is automatically hidden.

`Automatically hide notifications on ...` *Default: Info, Success*  
Decide when you want the notifications to automatically hide. Else you have to close every notification manually.

`Show 'Start Compiling' Notification` *Default: false*  
If enabled and you added the notification option in `Notifications`, you will see an info-message when compile process starts.


## Issues, questions & feedback

[Please post issues on GitHub](https://github.com/armin-pfaeffle/sass-autocompile/issues).

For other concerns like questions or feeback [have a look at the discussion thread on atom.io](https://discuss.atom.io/t/issues-questions-feedback-about-sass-autocompile/15233).



## Roadmap

- Add node-sass as dependency, so we do not need extra node.js and node-sass installation
- Extend atom notifications, so you can access css file or SASS file with error position directly from notification (like via panel)


## Changelog

**0.3.0 - 07.03.2015**
- Extended notifications
- Added panel with "Go to CSS file/error position" functionality
- Added options for better customization

**0.2.0 - 04.03.2015**
- Added keymap with ctrl-alt-shift-s shortcut for toggling auto compile
- Added option "enabled" for en-disabling auto compile
- Added option "always compress"

**0.1.0 - 03.03.2015**
- Initial version.
