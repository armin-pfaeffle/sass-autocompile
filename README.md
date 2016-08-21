# sass-autocompile package

Automatically compiles SASS files on save or via shortcut, with extensive configuration possibilities.

---

Inspired by [less-autocompile](https://atom.io/packages/less-autocompile) package, written by [lohek](https://atom.io/users/lohek), I have created a counterpart for [SASS](http://sass-lang.com/). This package can automatically compile SASS files (file ending: `.scss` or `.sass`) when you save it. Or you can use shortcuts to do that. Beside that this package is highly configurable to fit all your needs.



## Requirements

At the moment, you can only use this package when you install [node.js](http://nodejs.org/) and [node-sass](https://www.npmjs.com/package/node-sass) on you system. It's important that you install node-sass globally (command: `npm install node-sass -g`), so it's possible to access it via CLI.

The reason why *sass-autocompile* needs that is because node-sass is not compatible with atom shell in the current version (2.0.1), so it cannot be added as dependency. Probably that will change later, so you won't have to install node.js and node-sass additionally ‒ I put it to the roadmap.



## Usage

**Important:** *Install node.js and node-sass before, see [requirements](#requirements).*

### Basic SASS compilation

After you have installed this package, option **Compile on save** is enabled, so if you save a SASS file it's automatically compiled to a CSS file. Since version 0.10.0 you don't need a first-line-comment to compile SASS files any more, except you set this by option.

Alternatively you can use shortcuts for starting compilation:

1. `ctrl-shift-c`: Compile SASS file to a CSS file
2. `alt-shift-c` / `cmd-shift-c`: Direct compilation; replaces SASS text with compiled CSS

The third method is to use the Tree View context menu where you can find a **Compile SASS** item when right clicking on a file with `.scss` or `.sass` extension.

**Note**: When you want to compile a SASS file to a CSS File (→ *Compile to file*) the file extension must be `.scss` or `.sass`. You don't need a first-line-comment since version 0.10.0.

After compiling a SASS file, you should see a notification or a panel at the bottom of the editor, depending on your settings, showing you an error or success message. If you use *panel notification* ([see options](#options) -> `Notifications`) , you have the possibility to access the output CSS file by clicking on the compilation message. If compilation fails, you can even jump to error position in the corresponding SASS file where error occurred.

When using panel notification you can use **Show detailed output** link in the header caption of the panel to open detailed output of `node-sass` command (available since 0.7.0). Additionally you can set option [Show node-sass output after compilation](#show-node-sass-output-after-compilation) to automatically show output after compilation.


### Compile to file

This feature is the *default* behaviour and the method you will use most. It compiles a SASS file to a CSS file. When you save a SASS file or use the Tree View context menu this method is used.


### Direct compilation

When you want to instantly compile a SASS text, you can copy it to a new tab and press `alt-shift-c` / `cmd-shift-c` shortcut. This package then compiles the SASS input and replaces it with the compiled CSS.


### Options and parameters

Since version 0.10.0 there are many new options. So have a look at the package options and configure the general behaviour for compiling SASS files. In the [options](#options) section everything is explained in detail.

To overwrite general options in order to use specific configuration per project you can set parameters as comment in the first line. Have a look at the [parameters](#parameters) where any parameter is described and how you can use it.



## Options

- #### Compile on Save
    With this option you can en- or disable auto compiling on save functionality. If enabled and you save a file with `.scss` or `.sass` file extension, it's automatically compiled based on general options and on inline parameters, if defined.

    *Default:* `true`


- #### Compile files ...
    With this option you can decide if you want to compile every SASS file or only these which have a first-line-comment. Do I have t explain more about that? ;)

    *Default:* `Every SASS file`


- #### Compile Partials
    When you compile a Partial file (by saving it) and there is no first-line-comment, you can control if *sass-autocompile*  compiles this file or not.

    *Default:* `false`


- #### Ask for overwriting already existent files
    If enabled and output file already exists, you are asked if you want to overwrite it. Else files are automatically overwritten .

    *Default:* `false`


- #### Directly jump to error
    If enabled and you compile an erroneous SASS file, this file is opened and jumped to the problematic position.

    *Default:* `false`


- #### Show 'Compile SASS' item in Tree View context menu
    If enabled there is a menu item in the Tree View context menu called **Compile SASS**. This item is visible only on files that has `.scss` or `.sass` file extension.

    *Default:* `true`


- #### Compile with 'compressed' output style
    #### Compile with 'compact' output style
    #### Compile with 'nested' output style
    #### Compile with 'expanded' output style

    With these four options you can en- disable four different output styles. For each style the SASS file is compiled to the corresponding output file. So if you want to have the compressed and expanded style, activate that options, set the corresponding filename patterns and compile your SASS files.

    *Default:* `compressed: true`


- #### Filename pattern for 'compressed' compiled files
    #### Filename pattern for 'compact' compiled files
    #### Filename pattern for 'nested' compiled files
    #### Filename pattern for 'expanded' compiled files

    With this options you can define a filename pattern for the output filename of each output style, include a relative or absolute output path.

    You can use `$1` and `$2` as placeholder for the original basename respectively the file extension. Furthermore you can add a relative or an absolute path where compiled files are stored to. For example: When you compile `Foo.sass` and have `..\css\$1.minified.$2.css` as filename pattern, the resulting filename will be `Foo.minified.sass.css` and is stored in the relative path `..\css\`. Alternatively you can use absolute paths.

    *Default (compressed):* `$1.min.css`  
    *Default (compact):* `$1.compact.css`  
    *Default (nested):* `$1.nested.css`  
    *Default (expanded):* `$1.css`


- #### Indent type
    With this option you can set the indention type: space or tab.

    *Default:* `space`


- #### Indent width
    This option defines the number of spaces or tabs to be used for indention.

    *Default:* `2`


- #### Linefeed
    Used to determine whether to use `cr`, `crlf`, `lf` or `lfcr` sequence for line break.

    *Default:* `lf`


- #### Build source map
    If enabled a [source map](http://www.html5rocks.com/en/tutorials/developertools/sourcemaps/) is generated. Filename is automatically obtained by taking the output CSS filename and appending `.map`, e.g. `output.css.map`.

    *Default:* `false`


- #### Embed source map
    If enabled source map (see option [Build source map](#build-source-map)) is embedded as a data URI.

    *Default:* `false`


- #### Include contents in source map information
    If enabled contents are included in source map information.

    *Default:* `false`


- #### Include additional debugging information in the output CSS file
    If enabled additional debugging information are added to the output file as CSS comments. If CSS is compressed this feature is disabled by SASS compiler.

    *Default:* `false`


- #### Include paths
    Paths to look for files that are referenced by `@import` declarations (e.g. SASS frameworks or your own general SASS style collection). Multiple paths must be separated by commas. If you need spaces, commas or semicolons in a path, it must be surrounded by quotes.

    ```
    /path/to/your/project/lib, "/path to your/project/mod"
    ```

    *Default:* `''`


- #### Precision
    Used to determine how many digits after the decimal will be allowed. For instance, if you had a decimal number of 1.23456789 and a precision of 5, the result will be 1.23457 in the final CSS.

    *Default:* `5`


- #### Filename to custom importer
    If you want to use a custom import functionality, you can use this option to define a path to a JavaScript file that contains your code.

    *Default:* `''`


- #### Filename to custom functions
    If you have custom functions you want to include, you use this option to set a path to your corresponding JavaScript file.

    *Default:* `''`


- #### Notification type
    This options allows you to decide which feedback you want to see when SASS files are compiled: notification and/or panel.

    **Panel**: The panel is shown at the bottom of the editor. When starting the compilation it's only a small header with a throbber. After compilation a success or error message is shown with reference to the CSS file, or on error the SASS file. By clicking on the message you can access the CSS or error file.

    **Notification**: The default atom notifications are used for output.

    *Default:* `Panel`


- #### Automatically hide panel on ...
    Select on which event the panel should automatically disappear. If you want to hide the panel via shortcut, you can use `ctrl-alt-shift-h` / `ctrl-cmd-shift-h`.

    *Default:* `Success`


- #### Panel-auto-hide delay
    Delay after which panel is automatically hidden.

    *Default:* `3000`


- #### Automatically hide notifications on ...
    Decide when you want the notifications to automatically hide. Else you have to close every notification manually.

    *Default:* `Info, Success`


- #### Show 'Start Compiling' Notification
    If enabled and you added the notification option in `Notifications`, you will see an info-message when compile process starts.

    *Default:* `false`


- #### Show additional compilation info
    If enabled additional info like duration or file size is presented.

    *Default:* `true`


- #### Show node-sass output after compilation
    If enabled detailed output of node-sass command is automatically shown in a new tab after each compilation. So you can analyse the output, especially when using [@debug](http://sass-lang.com/documentation/file.SASS_REFERENCE.html#_5), [@warn](http://sass-lang.com/documentation/file.SASS_REFERENCE.html#_6) or [@error](http://sass-lang.com/documentation/file.SASS_REFERENCE.html#_7) in your SASS.

    *Default:* `false`


- #### Show warning when using old parameters
    If enabled any time you compile a SASS file und you use old inline parameters, an warning will be occur not to use them.

    *Default:* `true`


- #### 'node-sass' execution timeout
    Maximal amount of time (in milliseconds) node-sass is allowed to run. If it's set to 0, there is no time limit
    for execution.

    *Default:* 10000


- #### Path to 'node-sass' command
    Absolute path where 'node-sass' executable is placed (Mac OS X: `/usr/local/bin`, Linux: `?`). This option is especially for Mac OS and Linux users who have problems with permissions and seeing error message `command failed: /bin/sh: node-sass: command not found`.

    *Default:* `''`



## Parameters

Add following parameters in *comma-separated* way to the **first line** of your SASS file. See [examples](#examples) for demonstration:

- #### compileOnSave [ : true | false ]
    With this option you can control compile on save functionality by first line parameter. If you define this option, global option is overwritten. Examples:

    ```
    Enable compile on save
    // compileOnSave
    // compileOnSave: true

    Disable compile on save
    // !compileOnSave
    // compileOnSave: false
    ```

- #### compileCompressed
    #### compileCompact
    #### compileNested
    #### compileExpanded

    With these parameters you can define which output files should be generated. If one of these parameters is set, every other output styles are deactivated. So, if you have enabled all four output styles in global options and set e.g. `compileCompressed` in your inline parameters, only the compressed file is generated.

    **Note**: Please read documentation about patterns too! You can combine the *compile* and *filenamePattern* parameter.

- #### compressedFilenamePattern
    #### compactFilenamePattern
    #### nestedFilenamePattern
    #### expandedFilenamePattern

    With this parameter you can define a filename pattern for the output filename of each output style, including a relative or absolute output path.

    You can use `$1` and `$2` as placeholder for the original basename respectively the file extension. Furthermore you can add a relative or an absolute path where compiled files are stored to. For example: When you compile `Foo.sass` and have `..\css\$1.minified.$2.css` as filename pattern, the resulting filename will be `Foo.minified.sass.css` and is stored in the relative path `..\css\`.

    **Note**: There is a short form for combining the *compile* and *filenamePattern* parameter. For Example:
    ```
    // compileCompressed: /path/to/your/project/css/test.css
    ```
    This line tells sass-autocompile to output a **compressed** version of the SASS input and to store in in `test.css`.


- #### main
    Path to your main SASS file to be compiled. See http://sass-guidelin.es/#main-file for more info about that feature.

    *Value:* `<main.scss>`

    *Example:* `../main-scss.scss`


- #### indentType: space | tab
    Indention type: space or tab, default: space.

    *Value:* `space | tab`


- #### indentWidth: 0-10
    Indention width, maximum: 10, default: 2.

    *Value:* `<number>`


- #### linefeed:
    Defines the linefeed of output files.

    *Value:* `cr | crlf | lf | lfcr`


- #### sourceMap
    Creates a source map file if a filename is given or if true, source map filename
    is automatically set as CSS filename, extended with `.map`.

    *Value:* `true | false | <filename.css.map>`


- #### sourceMapEmbed
    If true source map is embedded as data URI.

    *Value:* `true | false`


- #### sourceMapContents
    If true the contents are included to the source map information

    *Value:* `true | false`


- #### sourceComments
    If true additional debugging information is added to the output file as CSS comments, but only if CSS is not compressed.

    *Value:* `true | false`


- #### includePath | includePaths
    Paths to look for files that are referenced by `@import` declarations (e.g. SASS frameworks or your own general SASS style collection). Can be relative or absolute paths. If spaces, commas or semicolons are needed, a path must be surrounded by quotes.

    When you want to apply multiple paths, you have to surround the paths by `[]`, see examples above.

    *Value:* `<path> | [<path1>, <path2>, ...]`

    *Examples:*

    ```
    includePath: ../my-framework/scss/
    OR
    includePath: [/path/to/your/project/lib, "/path to your/project/mod"]
    ```


- #### precision
    The amount of precision allowed in decimal numbers.

    *Value:* `<number>`


- #### importer
    Path to .js file containing custom importer.

    *Value:* `<filename.js>`


- #### functions
    Path to .js file containing custom functions.

    *Value:* `<filename.js>`



### Deprecated

These parameters are supported, but will be removed in future. Please use the corresponding parameters described above.

- #### out
    Defines the output filename pattern. If you set this parameter only one output file is generated. You should use this parameter in combination with `outputStyle`. If you use `out` but do **not** define `outputStyle` the default output style will be `compressed`.

    You can use `$1` and `$2` as placeholder for the original basename respectively the file extension. For example: When you compile `Foo.sass` and you define `$1.minified.$2.css` as out parameter, the resulting filename will be `Foo.minified.sass.css`.    

    *Values*: `<filename.css>`

- #### outputStyle
    You can define the output style. Have a look at [this page](https://web-design-weekly.com/2014/06/15/different-sass-output-styles/) where the difference is explained and shown in examples. If you set this parameter only one output file is generated.

    *Values*: `compressed | compact | nested | expanded`

- #### compress
    Instead of using `outputStyle` you can set this parameter in order to en- or disable compression. If enabled `outputStyle` is set to `compressed`, else to `nested`.

    If you use `compress` **and** `outputStyle`, compress is ignored.

    *Values*: `true | false`


### Examples

#### Basic usage

Defining a compressed output and save compiled CSS files to a relative CSS directory.
```
// compileCompressed, compressedFilenamePattern: ../css/$1.css
```
.. or in short version:
```
// compileCompressed: ../css/$1.css
```

Or you only want to overwrite some filename patterns?
```
// compressedFilenamePattern: ../css/min/$1.css, expandedFilenamePattern: ../css/$1.css
```

#### Main parameter

If you use `@import` command in SASS, you should define the `main` parameter in the *child files*. Imagine you have the following structure:
```
main.scss       // main file which imports colors and layout files
colors.scss     // contains color definitions
layout.scss     // contains layout definitions
```

Add this to `colors.scss` and `layout.scss` to enable auto compilation on saving each of these two *child files*.
```
// main: main.scss
```
The special about this parameter is, that when you save a child file, the `main.scss` is compiled, not the child file itself. So you can structure your SASS files, modify them and after saving, everything is compiled correctly, not only the saved file.




## Predefined shortcuts

- #### `ctrl-shift-c`
    Compiles current file to a CSS file (see [Compile to file)(#compile-to-file)]). This only works on files with `.scss` or `.sass` file extension.


- #### `alt-shift-c` / `cmd-shift-c`
    Direct compilation of current text (see [Direct compilation)(#direct-compilation)]). This works with every file, but throws an error if content is not valid SASS.


- #### `ctrl-alt-shift-s` / `ctrl-cmd-shift-s`
    Toggles *Compile on save* functionality. You will see a notification if you change this value.


- #### `ctrl-alt-shift-h` / `ctrl-cmd-shift-h`
    Hides the panel.



## Issues, questions & feedback

[Please post issues on GitHub](https://github.com/armin-pfaeffle/sass-autocompile/issues).

For other concerns like questions or feedback [have a look at the discussion thread on atom.io](https://discuss.atom.io/t/issues-questions-feedback-about-sass-autocompile/15233).



## Roadmap

- Add node-sass as dependency, so we do not need extra node.js and node-sass installation
- Recognize debug/info/error output and print it in info panel or print hint that such information is available
- Working on network directories/unc?



## Changelog

See [CHANGELOG.md](https://github.com/armin-pfaeffle/sass-autocompile/blob/master/CHANGELOG.md).
