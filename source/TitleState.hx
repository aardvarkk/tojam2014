package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.addons.display.FlxBackdrop;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.XboxButtonID;
import flixel.util.FlxTimer;
import flixel.util.FlxSpriteUtil;
import flixel.text.FlxText;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;

/**
* Title screen FlxState
*/
class TitleState extends FlxState
{
	private var _backdrop:FlxBackdrop;
	private var _moon:FlxSprite;
	private var _tower:FlxSprite;
	private var _rider:FlxSprite;
	private var _floor:FlxSprite;
	private var _snowEmitter:FlxEmitter;
	private var _start:FlxSprite;
	private var _title:FlxSprite;
	private var _riderTarget:FlxPoint;
	private var _towerTarget:FlxPoint;
	private var _moonTarget:FlxPoint;
	private var _introPlaying:Bool = true;
	private var _introTimer:Float = 0;
	private var _aux2:FlxText;
	private var _startTxt:FlxText;
	private var _infoTxt:FlxText;
	private var _selectionMade:Bool = false;

	override public function create():Void
	{
		#if debug
		FlxG.game.debugger.stats.visible = true;
		#end

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
		_backdrop = new FlxBackdrop(Reg.SNOWCLOUDS,1.5,0,true,false);
		_snowEmitter = new FlxEmitter(-240,-5);
		_snowEmitter.setSize(720,0);
		_snowEmitter.makeParticles(Reg.PARTICLE,400,0,true,0);
		_snowEmitter.setXSpeed(50,150); // 10-100 looks good - try it in ruins?
		_snowEmitter.setYSpeed(50,80);
		_snowEmitter.setAlpha(1,1,0,0.5);
		_snowEmitter.setRotation(0,0);
		_snowEmitter.start(false,10,0.007125);
		_floor = new FlxSprite(0, FlxG.height - 32, Reg.INTROFLOOR);
		_title = new FlxSprite(0,0,Reg.TITLE);
		_title.visible = false;
		//_tower = new FlxSprite(-130, 175, Reg.TOWER);
		_tower = new FlxSprite(256,170,Reg.TOWER);
		//_moon = new FlxSprite(246+36, 64-16, Reg.MOON);
		_moon = new FlxSprite(-100,64-16,Reg.MOON);
		//_moon.velocity.x = 15;
		// Title-specific Sprites - Really no need to have their own class UNLESS they get used again
		_rider = new FlxSprite(FlxG.width, FlxG.height - 78);
		_rider.loadGraphic(Reg.RIDER,true,true,48);
		_rider.animation.add("default",[0,1,2,3],12,true);
		_rider.animation.play("default");
		_rider.facing = FlxObject.LEFT;
		_riderTarget = new FlxPoint(140,FlxG.height - 78);
		_towerTarget = new FlxPoint(258,79);
		_moonTarget = new FlxPoint(282,64-16);
		_start = new FlxSprite(182, 221);
		_start.visible = false;
		_start.loadGraphic(Reg.START,true,false,120,12);
		_start.animation.add("default",[0,1],1,true);
		_start.animation.add("flicker",[0,1],4,true);
		_start.animation.play("default");
		_infoTxt = new FlxText(0, FlxG.height - 22, FlxG.width, "");
		_infoTxt.setFormat(null,8,0xfffffff,"center",1,0xff111112);

		// was testing some shit, but think I'll remove it after. See above notes.
		_moon.scrollFactor.x = 0.2;
		_rider.scrollFactor.x = 0;
		_tower.scrollFactor.x = 0;
		_floor.scrollFactor.x = 0;
		_infoTxt.scrollFactor.x = 0;
		_title.scrollFactor.x = 0;
		_start.scrollFactor.x = 0;

		// Add it all up
		add(_moon);
		add(_tower);
		add(_backdrop);
		add(_floor);
		add(_rider);
		add(_snowEmitter);
		add(_infoTxt);
		add(_start);
		add(_title);

		//FlxVelocity.moveTowardsPoint(_moon,_moonTarget,1,25000);
		_moon.velocity.y = 0;

		FlxG.sound.play("TitleBGM");
		FlxG.camera.flash(0xffffffff,0.5);

		super.create();
	}

	override public function update():Void
	{
		// Handle Inputs
		if (_introPlaying)
		{
			if (FlxG.keys.anyJustPressed(["SPACE", "X"]))
			{
				showMenu();
			}
		}
		else // On the menu
		{
			if (_selectionMade == false && FlxG.keys.anyJustPressed(["SPACE","X"]))
			{
				_selectionMade = true;
				goToMenu();
			}
		}

		// Intro movie
		_introTimer += FlxG.elapsed;

		if (_introPlaying)
		{
			if (_introTimer > 0.5)
			{
				_infoTxt.text = "One day, eons ago, a tower arose from the depths.";
			}
			if (_introTimer > 3.5)
			{
				_infoTxt.text = "It looms ever watchful, casting a darkness over us.";
			}
			if (_introTimer > 6.5)
			{
				_infoTxt.text = "For too long has it gone forgiven and forgotten.";
			}
			if (_introTimer > 9.5)
			{
				_infoTxt.visible = false;
			}
			// Move the tower around
			if (_tower.y > _towerTarget.y && _introTimer > 6)
			{
				_tower.velocity.y = -5;
			}
			// Move the rider around
			if (_introTimer > 13)
			{
				_rider.velocity.x = -18;
			}
			// End it
			if (_tower.y < _towerTarget.y)
			{
				_tower.y = _towerTarget.y;
				showMenu();
			}
		}
		else
		{
			
		}
		
		// Replay if it finishes
		if (_introTimer > 46 && !_selectionMade)
		{
			resetIntro();
		}

		// testy stuff
		_snowEmitter.x = FlxG.camera.scroll.x - 240; // keep the thing following the camera
		FlxG.camera.scroll.x -= 1;

		// Super
		super.update();
	}

	private function showMenu():Void
	{
		_introPlaying = false;
		_rider.setPosition(_riderTarget.x,_riderTarget.y);
		_tower.setPosition(_towerTarget.x,_towerTarget.y);
		//_moon.setPosition(_moonTarget.x,_moonTarget.y);
		_rider.velocity.set(0,0);
		_tower.velocity.set(0,0);
		//_moon.velocity.set(0,0);
		_infoTxt.visible = false;
		_start.visible = true;
		_title.visible = true;
		FlxG.sound.play("Growl",0.5);
		FlxG.sound.play("Howl");
		FlxG.sound.play("OddEcho");
		FlxG.camera.flash(0xffffffff,0.5);
	}

	private function goToMenu():Void
	{
		_start.animation.play("flicker");
		// How do we fade out the music?
		FlxG.sound.play("HowlBase");
		FlxG.sound.play("EndHowl");
		FlxG.cameras.fade(0xffffffff,2.5,false,switchToNewState);
	}

	private function switchToNewState():Void
	{
		//FlxG.switchState(new MenuState());
		FlxG.switchState(new TiledPlayState());
	}

	private function resetIntro():Void
	{
		// Fade out the music!!
		FlxG.cameras.fade(0xffffffff,2.5,false,FlxG.resetState);
	}

}