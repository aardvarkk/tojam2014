package; 

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;

class TiledPlayState extends FlxState
{
	public var level:TiledLevel;
	
	public var score:FlxText;
	public var status:FlxText;
	public var players:FlxGroup;
	public var grimmer:Grimmer;
	public var gewalt:Gewalt;
	public var floor:FlxObject;
	public var exit:FlxSprite;
	
	private static var youDied:Bool = false;
	
	override public function create():Void 
	{
		FlxG.mouse.visible = false;
		
		//super.create();
		bgColor = 0xffaaaaaa;
		
		// Load the level's tilemaps
		level = new TiledLevel("levels/ruins.tmx");
		
		players = new FlxGroup();

		// Add tilemaps
		add(level.bgTiles);
		add(level.backTiles);
		add(level.frontTiles);
		
		// Load player objects
		level.loadObjects(this);
		players.add(gewalt);
		players.add(grimmer);
		
		// Add background tiles after adding level objects, so these tiles render on top of player
		add(level.fgTiles);
		
		// // Create UI
		// score = new FlxText(2, 2, 80);
		// score.scrollFactor.set(0, 0); 
		// score.borderColor = 0xff000000;
		// score.borderStyle = FlxText.BORDER_SHADOW;
		// score.text = "SCORE: " + (coins.countDead() * 100);
		// add(score);
		
		// status = new FlxText(FlxG.width - 160 - 2, 2, 160);
		// status.scrollFactor.set(0, 0);
		// status.borderColor = 0xff000000;
		// score.borderStyle = FlxText.BORDER_SHADOW;
		// status.alignment = "right";
		
		// if (youDied == false)
		// 	status.text = "Collect coins.";
		// else
		// 	status.text = "Aww, you died!";
		
		// add(status);
	}
	
	override public function update():Void 
	{
		// controls and shit gotta go befire super.update apparently

		super.update();

		// Reset state
		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.resetState();
		}
		if (FlxG.keys.justPressed.SPACE)
		{
			if (gewalt.isSelected == true)
			{
				gewalt.isSelected = false;
				grimmer.isSelected = true;
			}
			else
			{
				gewalt.isSelected = true;
				grimmer.isSelected = false;
			}
		}
				
		// Collide with foreground tile layer
		//level.collideWithLevel(player);
		level.collideWithFront(grimmer);
		level.collideWithBack(gewalt);

		//FlxG.overlap(exit, player, win);
	}
}