package;

import flixel.util.FlxSave;
import flixel.group.FlxTypedGroup;

/**
 * Handy, pre-built Registry class that can be used to store 
 * references to objects and other things for quick-access. Feel
 * free to simply ignore it or change it in any way you like.
 */
class Reg
{
	static public inline var MAX_PLAYERS = 4;

	/**
	 * Generic levels Array that can be used for cross-state stuff.
	 * Example usage: Storing the levels of a platformer.
	 */
	static public var levels:Array<Dynamic> = [];
	/**
	 * Generic level variable that can be used for cross-state stuff.
	 * Example usage: Storing the current level number.
	 */
	static public var level:Int = 0;
	/**
	 * Size of smallest detail block
	 */
	static public var blockSize:Int = 16; 
	/**
	 * Generic scores Array that can be used for cross-state stuff.
	 * Example usage: Storing the scores for level.
	 */
	static public var scores:Array<Int> = [];
		
	static public function resetScores() 
	{
		scores = [];
	}

	static public function getScoreString()
	{
		var scoreString = "";
		for (i in 0...scores.length)
		{
			var score = Reg.scores[i];
			scoreString += '    $score\n';
		}
		return scoreString;
	}

	static public function getWinner():Int
	{
		var maxScoreIdx = 0;
		var maxScore = scores[0];
		for (i in 1...scores.length) 
		{
			if (scores[i] > maxScore) {
				maxScore = scores[i];
				maxScoreIdx = i;
			}
		}
		return maxScoreIdx;
	}

	/**
	 * Generic score variable that can be used for cross-state stuff.
	 * Example usage: Storing the current score.
	 */
	static public var score:Int = 0;
	/**
	 * Generic bucket for storing different <code>FlxSaves</code>.
	 * Especially useful for setting up multiple save slots.
	 */
	static public var saves:Array<FlxSave> = [];

	// This is important!
	// null means we'll use a gamepad, so players 0 and 1 will use gamepads in this case
	// the next number indicates which index in the keyset to use
	public static var KeyboardControlSet = [null, null, null, null];
	public static var SinglePlayerDebug = true; // used to control all players with 1 gamepad / key set by switching between them

	/**
	* Keyboard input sets
	*/
	public static var JUMP:Int = 10;
	public static var KEY1:Int = 20;
	public static var KEY2:Int = 40;
	public static var KEY3:Int = 80;
	public static var keyset:Array<Dynamic> =
	[
		["UP", "DOWN", "LEFT", "RIGHT", "Z", "X", "C", "V"],
		["NUMPADFIVE", "NUMPADTWO", "NUMPADONE", "NUMPADTHREE", "R", "T", "Y", "U"],
		//["NUMPADFIVE","NUMPADTWO","NUMPADONE","NUMPADTHREE","NUMPADSEVEN","NUMPADEIGHT","NUMPADNINE","NUMPADMINUS"],
		["W", "S", "A", "D", "R", "T", "Y", "U"],
		["I","K","J","L","O","P","SEMICOLON","QUOTE"]
	];
	/**
	 * Title screen images
	 */
	 
	 /**
	 * Background images
	 */
	 public static inline var CLOUDSFAR:String = "images/cloudsFar.png";
	 public static inline var CLOUDSMID:String = "images/cloudsMid.png";
	 public static inline var CLOUDSNEAR:String = "images/cloudsNear.png";
	 public static inline var MOUNTAINSFAR:String = "images/mountainsFar.png";
	 public static inline var BUILDINGSMID:String = "images/buildingsMid.png";
	 public static inline var BUILDINGSNEAR:String = "images/buildingsNear.png";
	 public static inline var JUNGLEFOLIAGE:String = "images/jungleforeground.png";
	 public static inline var JUNGLEFOLIAGE2:String = "images/jungleforegroundbot.png";
	 public static inline var MIST:String = "images/mist.png";
	 public static inline var MIST2:String = "images/mist2.png";
	 /**
	 * Game sprites
	 */
	 public static var MONKEYS:Array<String> = [
	 	"images/monkey.png",
		"images/monkey2.png",
		"images/monkey3.png",
		"images/monkey4.png"
	 ];

	 public static inline var BUBBLE:String = "images/bubble.png";

	 public static inline var UFO:String = "images/hand.png";

	 public static inline var CROSSHAIR:String = "images/crosshair.png";
	 /**
	 * Particles
	 */
	 public static inline var PARTICLE:String = "images/leaves02.png";
	 public static inline var BANANA:String = "images/banana.png";
	 public static inline var BOMB:String = "images/bomb.png";
	 public static inline var MISSILE:String = "images/missile.png";
	 public static inline var STINKBOMB:String = "images/stinkbomb.png";
	 public static inline var EXPLOSION:String = "images/explosion1.png";
	 public static inline var BANANAPOP:String = "images/bananapop.png";
	 /*
	 * Map tiles
	 */
	 public static inline var LEVELTILES:String = "images/tiles.png";

	 public static inline var RACERWIDTH:Int = 48;
	 public static inline var RACERHEIGHT:Int = 16;
	 public static inline var RACERSPEED:Int = 75;

	 public static inline var LEVELLENGTH:Int = 2048 * 4;
	 public static inline var DEMOSEED:Int = 635918;
}