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
		["UP", "DOWN", "LEFT", "RIGHT", "CONTROL", "ALT", "C", "V"],
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
	 /**
	 * Game sprites
	 */
	 public static inline var CORGI1:String = "images/corgi1.png";
	 public static inline var CORGI2:String = "images/corgi2.png";
	 public static inline var CORGI3:String = "images/corgi3.png";
	 public static inline var CORGI4:String = "images/corgi4.png";

	 public static inline var BUBBLE:String = "images/bubble.png";
	 /**
	 * Particles
	 */
	 public static inline var PARTICLE:String = "images/snowparticles.png";
	 /*
	 * Map tiles
	 */
	 public static inline var LEVELTILES:String = "images/tiles_ruins.png";

	 public static inline var RACERWIDTH:Int = 50;
	 public static inline var RACERHEIGHT:Int = 25;
	 public static inline var RACERSPEED:Int = 75;

	 public static inline var LEVELLENGTH:Int = 1024;

	 public static inline var LINESPACE:Int = 25;
}