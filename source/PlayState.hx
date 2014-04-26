package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;

import flixel.text.FlxText;

import flixel.ui.FlxButton;

import flixel.util.FlxMath;
import flixel.util.FlxTimer;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxPoint;

import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;

import flixel.tile.FlxTileblock;

import flixel.addons.display.FlxBackdrop;

import flixel.effects.particles.FlxEmitter;

import flixel.input.mouse.FlxMouse;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.PS3ButtonID;
import flixel.input.gamepad.XboxButtonID;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	// Variables live here
	private var _backdropFar:FlxBackdrop;
	private var _backdropMid:FlxBackdrop;
	private var _backdropNear:FlxBackdrop;
	private var _foreground:FlxBackdrop;
	private var _weatherEmitter:FlxEmitter;
	private var _infoText:FlxText;
	private var _players:FlxGroup;
	private var _p1:Player;
	private var _p2:Player;
	private var _p3:Player;
	private var _p4:Player;
	private var _buildings:RandomBuildings;

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		#if debug
		FlxG.game.debugger.stats.visible = true;
		#end

		//FlxG.mouse.visible = false;

		FlxG.cameras.bgColor = 0xff486878;

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
		}

		// WHERE I LEFT OFF - For autoscrolling backgrounds, for now, the best solution
		// is probably to just make an animated thing manually
		// and in other situations, we'll try having a camera just for the background
		// since we don't want the split screen cameras to fuck it up

		// Initialize things
		_backdropFar = new FlxBackdrop(Reg.SNOWCLOUDS,1.5,0,true,false);
		_weatherEmitter = new FlxEmitter(-240,-5);
		_weatherEmitter.setSize(720,0);
		_weatherEmitter.makeParticles(Reg.PARTICLE,400,0,true,0);
		_weatherEmitter.setXSpeed(-50,-150); // 10-100 looks good - try it in ruins?
		_weatherEmitter.setYSpeed(50,80);
		_weatherEmitter.setAlpha(1,1,0,0.5);
		_weatherEmitter.setRotation(0,0);
		_weatherEmitter.start(false,10,0.007125);

		// Add objects to game from back to front
		add(_backdropFar);
		add(_weatherEmitter);

		// The last stuff
		//FlxG.sound.play("");
		FlxG.camera.flash(0xffffffff,0.25);

		// Create the random buildings
		_buildings = new RandomBuildings(
			FlxG.height, 
			FlxG.width * 10, 
			2,
			15,
			1,
			5,
			3
			);
		add(_buildings);

		// Super
		super.create();
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{

		//FlxG.camera.scroll.x +=1;

		// Super
		super.update();
	}	
}