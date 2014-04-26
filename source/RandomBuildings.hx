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
	public function new(Seed:Int, SizeX:Int, SizeY:Int, MinBuildingX:Int, MaxBuildingX:Int, MinDX:Int, MaxDX:Int, MaxDY:Int)
	{
		super();

		FlxRandom.globalSeed = Seed;
		
		var maxH = Math.floor(FlxG.height / Reg.blockSize - 1);
		var curX = 0;
		var buildingW = 0;
		var prvBuildingH = FlxRandom.intRanged(0, maxH);
		var buildingH = 0;
		var tileIndexAdd = 0;
		while (curX + buildingW < SizeX) {
			buildingW = FlxRandom.intRanged(MinBuildingX, MaxBuildingX);

			// Don't allow same height as previous building (looks better)
			while (buildingH == prvBuildingH) 
			{			
				buildingH = FlxRandom.intRanged(1, Std.int(Math.min(prvBuildingH + MaxDY, maxH)));
			}

			var X = curX;
			var Y = FlxG.height - buildingH * Reg.blockSize;
			// FlxG.log.add('Add building @ $X, $Y of block size $buildingW x $buildingH');

			add(new Building(X, Y, buildingW, buildingH, 8 * 15 + 9 + tileIndexAdd));
			tileIndexAdd = tileIndexAdd == 0 ? 1 : 0;

			var shiftX = FlxRandom.intRanged(MinDX, buildingW + MaxDX);
			curX += shiftX * Reg.blockSize;
			// FlxG.log.add('Shifted forward by $shiftX blocks');
			prvBuildingH = buildingH;
		}
	}
}