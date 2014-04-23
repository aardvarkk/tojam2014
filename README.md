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
