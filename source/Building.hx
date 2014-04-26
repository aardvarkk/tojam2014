package;

import flixel.FlxSprite;
import flixel.util.FlxColor;

class Building extends FlxSprite
{
	// Width and height in BLOCKS
	public function new(Width:Int, Height:Int)
	{
		super();
		
		makeGraphic(Width * Reg.blockSize, Height * Reg.blockSize, FlxColor.CHARTREUSE);
	}
}