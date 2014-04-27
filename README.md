# Build Process
## Windows
1. [Install Haxe](http://haxe.org/download)
 * Haxe will add environment variables `HAXEPATH` and `NEKO_INSTPATH` and add them to the `PATH`
1. `haxelib install lime`
1. `haxelib run lime setup`
1. `lime install openfl`
1. `haxelib install flixel`
1. `haxelib install flixel-addons`
1. `haxelib install flixel-ui`
1. `lime test windows`
1. [Install haxe-sublime-bundle](https://github.com/clemos/haxe-sublime-bundle)
 * `Ctrl-Shift-B` to set build target
 * `Ctrl-Enter` to build and run
 * Check snippets inside command palette
 
## OSX
1. `sudo haxelib selfupdate`
1. `haxelib upgrade`

## Haxe bugs
1. system/FlxSound line 241 -- comment out entire if/else block

# [Tiled](http://www.mapeditor.org/) (Map Editor)
1. See [HaxeFlixel Demos](http://haxeflixel.com/demos/) for example usage
