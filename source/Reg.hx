package;

import flixel.util.FlxSave;

/**
 * Handy, pre-built Registry class that can be used to store 
 * references to objects and other things for quick-access. Feel
 * free to simply ignore it or change it in any way you like.
 */
class Reg
{
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
	static public var scores:Array<Dynamic> = [];
	
	static public function getScoreString(?Sorted:Bool = true)
	{
		var scoreString = "";
		for (i in 0...scores.length)
		{
			var score = Reg.scores[i];
			scoreString += 'P${i+1}:$score\n';
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
	/**
	* Keyboard input sets
	*/
	public static var UseKeyboard:Bool = true; // false if controllers?
	public static var UseGamepad:Bool = false;
	public static var SingleControllerMode:Bool = true; // turn off for multiplayer
	public static var JUMP:Int = 10;
	public static var KEY1:Int = 20;
	public static var KEY2:Int = 40;
	public static var KEY3:Int = 80;
	public static var keyset:Array<Dynamic> =
	[
		["UP", "DOWN", "LEFT", "RIGHT", "Z", "X", "C", "V"],
		["W", "S", "A", "D", "R", "T", "Y", "U"],
		["I","K","J","L","O","P","SEMICOLON","QUOTE"],
		["NUMPADFIVE","NUMPADTWO","NUMPADONE","NUMPADTHREE","NUMPADSEVEN","NUMPADEIGHT","NUMPADNINE","NUMPADMINUS"]
	];
	/**
	 * Title screen images
	 */
	 
	 /**
	 * Background images
	 */
	 public static inline var SNOWCLOUDS:String = "images/scroll_menuclouds.png";
	 public static inline var CLOUDSFAR:String = "images/cloudsFar.png";
	 public static inline var CLOUDSMID:String = "images/cloudsMid.png";
	 public static inline var CLOUDSNEAR:String = "images/cloudsNear.png";
	 public static inline var MOUNTAINSFAR:String = "images/mountainsFar.png";
	 public static inline var BUILDINGSMID:String = "images/buildingsMid.png";
	 public static inline var BUILDINGSNEAR:String = "images/buildingsNear.png";
	 public static inline var BACKGROUND:String = "images/background.png";
	 /**
	 * Game sprites
	 */
	 public static inline var MONKEY1:String = "images/monkey.png";
	 public static inline var MONKEY2:String = "images/monkey2.png";
	 public static inline var MONKEY3:String = "images/monkey3.png";
	 public static inline var MONKEY4:String = "images/monkey4.png";
	 public static inline var CORGI1:String = "images/corgi1.png";
	 public static inline var CORGI2:String = "images/corgi2.png";
	 public static inline var CORGI3:String = "images/corgi3.png";
	 public static inline var CORGI4:String = "images/corgi4.png";

	 public static inline var BUBBLE:String = "images/bubble.png";
	 public static inline var BEAM:String = "images/beam.png";

	 public static inline var UFO:String = "images/ufo.png";
	 /**
	 * Particles
	 */
	 public static inline var PARTICLE:String = "images/leaves02.png";
	 public static inline var BOMB:String = "images/enemydeath.png";
	 /*
	 * Map tiles
	 */
	 public static inline var LEVELTILES:String = "images/tiles_ruins.png";

	 public static inline var RACERWIDTH:Int = 48;
	 public static inline var RACERHEIGHT:Int = 16;
	 public static inline var RACERSPEED:Int = 75;

	 public static inline var LEVELLENGTH:Int = 2048 * 4;
}