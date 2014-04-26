package;

import flixel.FlxSprite;

class Racer extends FlxSprite
{
	public function new(X:Int, Y:Int)
	{
		super(X, Y);

		makeGraphic(Reg.RACERWIDTH, Reg.RACERHEIGHT, flixel.util.FlxColor.AQUAMARINE);

		velocity.x = Reg.RACERSPEED;
	}
}