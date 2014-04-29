package;

import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;

class Backdrop extends FlxBackdrop
{
	public function new(BackdropInfo:Array<Dynamic>)
	{
		trace('Making backdrop from Image ${BackdropInfo[0]} with ScrollX ${BackdropInfo[1]} and Offset ${BackdropInfo[2]}');
		super(BackdropInfo[0], BackdropInfo[1], 0, true, false);

		// Third parameter is a shift from the bottom upward
		if (BackdropInfo[2] != null) {
			y = FlxG.height - BackdropInfo[2];
		}
	}
}