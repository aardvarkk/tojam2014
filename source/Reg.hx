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
	public static var JUMP:Int = 10;
	public static var KEY1:Int = 20;
	public static var KEY2:Int = 40;
	public static var KEY3:Int = 80;
	public static var keyset:Array<Dynamic> =
	[
		["UP", "DOWN", "LEFT", "RIGHT", "Z", "X"],
		["UP", "DOWN", "LEFT", "RIGHT", "PERIOD", "SLASH"],
		["T", "G", "F", "H", "Z", "X"]
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

	 /**
	 * Particles
	 */
	 public static inline var PARTICLE:String = "images/snowparticles.png";
	 /*
	 * Map tiles
	 */
	 public static inline var LEVELTILES:String = "images/tiles_ruins.png";
}