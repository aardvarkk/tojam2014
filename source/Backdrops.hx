package;

import flixel.group.FlxTypedGroup;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxState;

// Would like to make this a FlxTypedGroup<FlxBackdrop> (so we can do add() instead of State.add())
// But the program crashes -- I think there's probably a bug for TypedGroups of Backdrops...
class Backdrops
{
	public function new(State:FlxState, BackdropInfos:Array<Dynamic>)
	{
		for (bdi in BackdropInfos) {
			State.add(new Backdrop(bdi));
		}
	}
}