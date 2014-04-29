package;

import flixel.FlxSprite;

class Racer extends FlxSprite
{
	public function new(X:Int, Y:Int)
	{
		super(X, Y);

		loadGraphic(Reg.HANDS, true, 48, 32);
		width = 32;
		offset.x = 8; 

		velocity.x = Reg.RACERSPEED;
	}
}