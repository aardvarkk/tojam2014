package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class Building extends FlxSprite
{
	// Width and height in BLOCKS
	public function new(Width:Int, Height:Int)
	{
		super();

		var sprite:FlxSprite = new FlxSprite().loadGraphic(Reg.LEVELTILES, true, Reg.blockSize, Reg.blockSize);
		sprite.animation.frameIndex = 8;
		sprite.drawFrame();

		makeGraphic(Width * Reg.blockSize, Height * Reg.blockSize, FlxColor.CHARTREUSE);

		for (r in 0...Height) {
			for (c in 0...Width) {
				stamp(sprite, c * Reg.blockSize, r * Reg.blockSize);
				FlxG.log.add("Row " + r + ", Column " + c);
			}
		}
	}
}