package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxRandom;

class Building extends FlxSprite
{
	// Width and height in BLOCKS
	public function new(X:Int, Y:Int, Width:Int, Height:Int, TileIndex:Int)
	{
		super(X, Y);
		moves = false;
		immovable = true;

		// FlxG.log.add('Building at $X,$Y,$Width,$Height');
		var sprite:FlxSprite = new FlxSprite().loadGraphic(Reg.LEVELTILES, true, Reg.blockSize, Reg.blockSize);
		sprite.animation.frameIndex = TileIndex;
		sprite.drawFrame();

		// Choose random full-alpha color
		var color = FlxRandom.int();
		color = color | 0xff000000;
		makeGraphic(Width * Reg.blockSize, Height * Reg.blockSize, color);

		for (r in 0...Height) {
			for (c in 0...Width) {
				stamp(sprite, c * Reg.blockSize, r * Reg.blockSize);
				// FlxG.log.add("Row " + r + ", Column " + c);
			}
		}
	}
}