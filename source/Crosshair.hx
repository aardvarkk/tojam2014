package;

import flixel.FlxG;
import flixel.FlxSprite;

class Crosshair extends FlxSprite
{
	public function new()
	{
		super(0, 0);
	
		offset.x = 16;
		offset.y = 16;
		width = 16;
		height = 16;
		visible = true;
	}

	public function init()
	{
		loadRotatedGraphic(Reg.CROSSHAIR, 180);
	}
}