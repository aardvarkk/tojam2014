package;

import openfl.Assets;
import haxe.io.Path;
import haxe.xml.Parser;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectGroup;
import flixel.addons.editors.tiled.TiledTileSet;

/**
 * ...
 * @author Samuel Batista
 */
class TiledLevel extends TiledMap
{
	// For each "Tile Layer" in the map, you must define a "tileset" property which contains the name of a tile sheet image 
	// used to draw tiles in that layer (without file extension). The image file must be located in the directory specified bellow.
	private inline static var c_PATH_LEVEL_TILESHEETS = "levels/";
	
	// Array of tilemaps used for collision
	public var frontTiles:FlxGroup; // Grimmer's layer
	public var backTiles:FlxGroup; // Gewalt's layer
	public var bgTiles:FlxGroup; // Tiles used behind - just for effect, no collision
	public var fgTiles:FlxGroup; // Tiles used in front - just for effect, no collision
	private var collidableTileLayers:Array<FlxTilemap>; // both layers, for use by enemies that collide with both.
	
	public function new(tiledLevel:Dynamic)
	{
		super(tiledLevel);
		
		frontTiles = new FlxGroup();
		backTiles = new FlxGroup();
		bgTiles = new FlxGroup();
		fgTiles = new FlxGroup();
		
		FlxG.camera.setBounds(0, 0, fullWidth, fullHeight, true);
		
		// Load Tile Maps
		for (tileLayer in layers)
		{
			var tileSheetName:String = tileLayer.properties.get("tileset");
			
			if (tileSheetName == null)
				throw "'tileset' property not defined for the '" + tileLayer.name + "' layer. Please add the property to the layer.";
				
			var tileSet:TiledTileSet = null;
			for (ts in tilesets)
			{
				if (ts.name == tileSheetName)
				{
					tileSet = ts;
					break;
				}
			}
			
			if (tileSet == null)
				throw "Tileset '" + tileSheetName + " not found. Did you mispell the 'tileset' property in " + tileLayer.name + "' layer?";
				
			var imagePath 		= new Path(tileSet.imageSource);
			var processedPath 	= c_PATH_LEVEL_TILESHEETS + imagePath.file + "." + imagePath.ext;
			
			var tilemap:FlxTilemap = new FlxTilemap();
			tilemap.widthInTiles = width;
			tilemap.heightInTiles = height;
			tilemap.loadMap(tileLayer.tileArray, processedPath, tileSet.tileWidth, tileSet.tileHeight, 0, 1, 1, 1);
			// If you want to use processed path, it seems you cannot change the path of an image after connecting it the first time
			// so don't fuck it up.
			//tilemap.loadMap(tileLayer.tileArray, "/levels/ruins.png", tileSet.tileWidth, tileSet.tileHeight, 0, 1, 1, 1);
			
			if (tileLayer.properties.contains("bg"))
			{
				bgTiles.add(tilemap);
			}
			else if (tileLayer.properties.contains("fg"))
			{
				fgTiles.add(tilemap);
			}
			else
			{
				if (collidableTileLayers == null)
					collidableTileLayers = new Array<FlxTilemap>();
				
				if (tileLayer.properties.contains("front"))
				{
					frontTiles.add(tilemap);
				}
				else if (tileLayer.properties.contains("back"))
				{
					backTiles.add(tilemap);
				}
				// and add it to the list of both for enemy usage, regardless
				collidableTileLayers.push(tilemap);
			}
		}
	}
	
	public function loadObjects(state:TiledPlayState)
	{
		for (group in objectGroups)
		{
			for (o in group.objects)
			{
				loadObject(o, group, state);
			}
		}
	}
	
	private function loadObject(o:TiledObject, g:TiledObjectGroup, state:TiledPlayState)
	{
		var x:Int = o.x;
		var y:Int = o.y;
		
		// objects in tiled are aligned bottom-left (top-left in flixel)
		if (o.gid != -1)
			y -= g.map.getGidOwner(o.gid).tileHeight;
		
		switch (o.type.toLowerCase())
		{
			case "grimmer":
				var grimmer = new Grimmer(x, y);
				FlxG.camera.follow(grimmer);
				state.grimmer = grimmer;
				state.add(grimmer);
			
			case "gewalt":
				var gewalt = new Gewalt(x, y);
				FlxG.camera.follow(gewalt);
				state.gewalt = gewalt;
				state.add(gewalt);
				
			case "floor":
				var floor = new FlxObject(x, y, o.width, o.height);
				//state.floor = floor;
				
			case "coin":
				var tileset = g.map.getGidOwner(o.gid);
				var coin = new FlxSprite(x, y, c_PATH_LEVEL_TILESHEETS + tileset.imageSource);
				//state.coins.add(coin);
				
			case "exit":
				// Create the level exit
				var exit = new FlxSprite(x, y);
				exit.makeGraphic(32, 32, 0xff3f3f3f);
				exit.exists = false;
				//state.exit = exit;
				//state.add(exit);
		}
	}
	
	public function collideWithLevel(obj:FlxObject, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool
	{
		if (collidableTileLayers != null)
		{
			for (map in collidableTileLayers)
			{
				// IMPORTANT: Always collide the map with objects, not the other way around. 
				//			  This prevents odd collision errors (collision separation code off by 1 px).
				return FlxG.overlap(map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate);
			}
		}
		return false;
	}

	public function collideWithFront(obj:FlxObject, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool
	{
		if (frontTiles != null)
		{
			return FlxG.overlap(frontTiles, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate);
		}
		return false;
	}

	public function collideWithBack(obj:FlxObject, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool
	{
		if (backTiles != null)
		{
			return FlxG.overlap(backTiles, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate);
		}
		return false;
	}
}