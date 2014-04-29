package;

import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;

class Backdrop extends FlxBackdrop
{
	public function new(BackdropInfo:Array<Dynamic>)
	{
		super(BackdropInfo[0], BackdropInfo[1], 0, true, false);

		// Third parameter is a shift from the bottom upward
		if (BackdropInfo[2] != null) {
			y = FlxG.height - BackdropInfo[2];
		}
	}
}