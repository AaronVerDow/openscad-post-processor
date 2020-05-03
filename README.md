# OpenSCAD Post Processor

This repo includes some scripts for automaically generating output from OpenSCAD.

There are several actions:
* Preview: Open views of the scad file. 
* Render: Generate output files.  This can be done automatically by using hooks.
* Final: Manually generate output files.  This is for rendering output that takes too long to do automatically.
* Build README: Automatically build a README.md that includes images

Hooks:
* git commit: automatically add output to an asset branch of your repo
* maslow community garden: automatically build output for a Maslow community garden compatible repository
* README builder: Builds a README.md from scad source that includes comments and any generated pictures.
* vim preview: Automatically open and close the previews of a file.

## Render
Declare output by adding comments above modules:

```
// RENDER stl 
// RENDER png 
module assembled() {
    shelves();
    boxes();
}

// RENDER dxf
module cutsheet() {
    shelf();
    side();
}
```

Usage: `// RENDER` followed by the filetype. A list of available options can be seen by running `openscad --help`.  Any remaining args on a RENDER line will be passed to openscad.  This will allow rendering the same module with different options or to customize camera settings.

Rendering is done through an automatically built temporary file which will `use` the .scad file and then call only the required module.  This will allow scratch work to be done outside the modules without affecting the output.

### Naming

Only passing the filetype (no dots) will result in an automatically generated name based on the script name, module name, and filetype.  For example: rendering a png of the assembled module in bankers_shelves.scad will create the file bankers_shelves_assembled.png 

Regardless of where the processing script is called from all paths are relative to the location of the scad file being processed.

A custom filename can be specified instead of the filetype.  `// RENDER output/bankers_shelves.png` will attempt to write to "output/bankers_shelves.png" instead of auto generating a name.  For manually specified names:
* A dot must be included in the name
* It must end in a valid filetype for openscad to process it
* No spaces
* Asbolute or relative paths can be used

Custom names will be evaluated so variables may be used.  The following variables are supported:
* filename: name of the openscad file excluding directories
* basename: name of the openscad file excluding directories and file extension
* module: name of the module
* reporoot: relative path to git repository root from openscad file

### Render SCAD

A custom filetype "scad" can be used with a RENDER statement.  This will create an scad file that uses the source script and calls the specific module.  This is handy for opening mutliple instances of OpenSCAD at one time to see multiple views of the same project.

Unlike the other filetypes an scad render will never overwrite existing files.  This is to protect your source code from accidental deletion.

### Render obj

A custom filetype has also been added for exporting obj files.  This will create a 3D model of the module in a format that preserves colors.  This is accomplished by rendering an stl file per color, then combining them in blender with the colors applied.  For this to work there are several requirements:

* Blender must be installed
* The variable COLOR must be defined as empty.
* The if_color() module must be used in place of color().  (Code below.)
* Colors must be defined in a format compatible with https://pypi.org/project/colour/
* Colors cannot be stored in variables. (For now)
* Colors cannot be added to the first object in a difference operation.  It must be added above, over the whole difference call.  In general adding color at the highest level possible is safest.

```
COLOR="";

module if_color(_color) {
    if(COLOR == _color || COLOR == "")
    color(_color)
    children();
}
```

Known working software for using the colorized output:
* Blender
* Sketchfab
* VR Model Viewer

## Preview

Render builds files for use at a later time.  Preview will build files to a temporary location and then open them immdediately.  It can be used to easily open up several instances of openscad at once.

Supported filetypes are:
* scad
* png

## Final

Final is the same as render, but it will not be included in any git or vim hooks.  This is where the really heavy work should be done.

# Hooks

## vimrc

Add this to ~/.vimrc for automatic renders and previews:

```
" Open preview windows on open
au BufRead *.scad silent exec "!openscad-preview <afile> > /dev/null 2>&1 &"

" Close preview windows when quitting
au VimLeave *.scad silent exec "!openscad-preview --kill <afile> > /dev/null 2>&1 &"

" Render output on write
au BufWritePost *.scad silent exec "!openscad-render <afile> > /dev/null 2>&1 &"
```

## git

todo
