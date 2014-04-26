package;

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
	public function new(SizeX:Int, SizeY:Int, MinBuildingX:Int, MaxBuildingX:Int, MinDX:Int, MaxDX:Int, MaxDY:Int)
	{
		super();

		add(new Building(MinBuildingX, 6));
	}
}