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

### Examples
When you add th `out` parameter your SASS file is compiled to `main.css` in the relative path `../css/`.
```
// out: ../css/main.css
```

To additionally compress the output you have to add `compress: true`:
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


## Issues, questions & feedback

[Please post issues on GitHub](https://github.com/armin-pfaeffle/sass-autocompile/issues).

For other concerns like questions or feeback [have a look at the discussion thread on atom.io](https://discuss.atom.io/t/issues-questions-feedback-about-sass-autocompile/15233).


## Roadmap

- Add node-sass as dependency, so we do not need extra node.js and node-sass installation


## Changelog

- *03.03.2015*: Initial version
