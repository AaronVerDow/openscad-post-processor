# OpenSCAD Render

This repo includes some scripts for generating output from OpenSCAD.

Features:
* All definitions are done by adding comments within the openscad script.
* Only the specific module will be rendered, objects left in global space will be ignored.
* Create obj files that preserve colors defined in openscad.

# openscad-render

```
openscad-render <openscad file> [output filetype|output filename] [module] [extra args]
```

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

## Naming

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

## Filetypes

All OpenSCAD filetypes are supported, as well as the custom types below:

* `scad`: outputs a file that calls the specific module
* `obj`: creates Blender obj, with colors applied
* `gif`: builds an animated gif with $t oscilating between 0 and 1
* `flatgif`: same as `gif`, but with camera set for 2D models  
* `svg2png`: exports as svg, removes border line, sets fill to black, and converts to png. Useful for printing 2D designs.

## scad 

"scad" can be used with a RENDER statement to create an scad file that will display only a specific function.  This is handy for opening mutliple instances of OpenSCAD at one time to see multiple views of the same project.

Given the example source:

_bankers_shelf.scad_
```
// RENDER scad
module assembled() {
    shelves();
    boxes();
}
```

The following would be generated:

_bankers_shelf_assembled.scad_
```
use <bankers_shelf.scad>; assembled();
```

Unlike the other filetypes an scad render will never overwrite existing files.  This is to protect your source code from accidental deletion. (It also doesn't really have to change.)

Extra args on this render line will be passed into the module.  For example:

_bankers_shelf.scad_
```
// RENDER scad show_boxes=1
module assembled(show_boxes="") {
    shelves();
    if(show_boxes)
    boxes();
}
```

Would render:

_bankers_shelf_assembled.scad_
```
use <bankers_shelf.scad>; assembled(show_boxes=1);
```

### obj

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
