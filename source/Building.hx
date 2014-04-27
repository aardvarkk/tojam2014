package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxRandom;

class Building extends FlxSprite
{
	// Width and height in BLOCKS
	public function new(X:Int, Y:Int, Width:Int, Height:Int)
	{
		super(X, Y);
		moves = false;
		immovable = true;

		// Choose whether we're tileset green or yellow (0 or 1)
		var tileset = FlxRandom.intRanged(0, 4);

		// FlxG.log.add('Building at $X,$Y,$Width,$Height');
		var sprite:FlxSprite = new FlxSprite().loadGraphic(Reg.LEVELTILES, true, Reg.blockSize, Reg.blockSize);

		// Choose random full-alpha color (useful for debugging)
		var color = FlxRandom.int();
		color = color | 0xff000000;
		makeGraphic(Width * Reg.blockSize, Height * Reg.blockSize, color);

		for (r in 0...Height) {
			for (c in 0...Width) {

				// Choose a random tile from the tileset
				sprite.animation.frameIndex = tileset * 16 + FlxRandom.intRanged(0, 15);
				sprite.drawFrame();

				stamp(sprite, c * Reg.blockSize, r * Reg.blockSize);
				// FlxG.log.add("Row " + r + ", Column " + c);
			}
		}
	}
}