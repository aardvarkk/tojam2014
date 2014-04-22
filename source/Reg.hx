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
	 * Title screen images
	 */
	 public static inline var RIDER:String = "images/rider.png";
	 public static inline var MOON:String = "images/intromoon.png";
	 public static inline var TOWER:String = "images/newtowersmall.png";
	 public static inline var TITLE:String = "images/hyliantitle.png";
	 public static inline var START:String = "images/start.png";
	 /**
	 * Background images
	 */
	 public static inline var SNOWCLOUDS:String = "images/scroll_snowclouds.png";
	 public static inline var INTROFLOOR:String = "images/scroll_introFloor.png";
	 /**
	 * Game sprites
	 */
	 public static inline var GRIMMER:String = "images/grimmer.png";
	 public static inline var GEWALT:String = "images/gewalt.png";
	 /**
	 * Particles
	 */
	 public static inline var PARTICLE:String = "images/snowparticles.png";
}