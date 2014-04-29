package;

import flixel.FlxG;
import flixel.util.FlxRandom;
import flixel.group.FlxGroup;

class RandomBuildings extends FlxGroup
{
	// Everything is based on the block size
	// SizeX: Total level width in pixels (not blocks!)
	// SizeY: Total level width in pixels (not blocks!)
	// BlockSize: Size of blocks used to make the level
	// MinBuildingX: Minimum building width in blocks
	// MaxBuildingX: Maximum building width in blocks
	// MinDX: Minimum distance between left sides of buildings in blocks
	// MaxDX: Maximum distance between buildings in blocks
	// MaxDY: Maximum upward distance between buildings in blocks (maximum downward is just SizeY/BlockSize)
	public function init(
		Seed:Int, 
		SizeX:Int, 
		?SizeY:Int = null,
		?MinBuildingX:Int = 2,
		?MaxBuildingX:Int = 10, 
		?MinDX:Int = 1, 
		?MaxDX:Int = 5, 
		?MaxDY:Int = 3
		)
	{
		// If they want a seed, use it
		if (Seed >= 0) {
			FlxRandom.globalSeed = Seed;			
		}
		
		// Workaround for default value of FlxG.height (not a constant)
		if (SizeY == null) {
			SizeY = FlxG.height;
		}

		var maxH = Math.floor(FlxG.height / Reg.BLOCKSIZE - 1);
		var curX = 0;
		var buildingW = 16;
		var buildingH = 4;
		var prvBuildingH = 0;
		while (curX + buildingW < SizeX) {

			var X = curX;
			var Y = FlxG.height - buildingH * Reg.BLOCKSIZE;
			// FlxG.log.add('Add building @ $X, $Y of block size $buildingW x $buildingH');

			add(new Building(X, Y, buildingW, buildingH));

			var shiftX = FlxRandom.intRanged(MinDX, buildingW + MaxDX);
			curX += shiftX * Reg.BLOCKSIZE;
			// FlxG.log.add('Shifted forward by $shiftX blocks');
			prvBuildingH = buildingH;

			// Choose building dimensions
			// Don't allow same height as previous building (looks better)
			buildingW = FlxRandom.intRanged(MinBuildingX, MaxBuildingX);
			while (buildingH == prvBuildingH) 
			{			
				buildingH = FlxRandom.intRanged(1, Std.int(Math.min(prvBuildingH + MaxDY, maxH)));
			}
		}
	}
}