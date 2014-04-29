package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.system.replay.FlxReplay;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.addons.display.FlxBackdrop;
import flixel.effects.particles.FlxEmitter;
import openfl.Assets;
import flixel.FlxObject;
import flixel.input.gamepad.PS4ButtonID;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	private var _backdropsFar:Backdrops;
	private var _backdropsMid:Backdrops;
	private var _backdropsNear:Backdrops;
	private var _buildings:RandomBuildings;
	private var _weatherEmitter:FlxEmitter;
	private var _p:Player;
	private var _p2:Player;
	private var _p3:Player;
	private var _p4:Player;
	private var _replay:FlxReplay;
	private var choosePlayers:FlxText;
	private var names:FlxText;

	private static var recording:Bool = false;
	private static var replaying:Bool = false;
	private static var playbackOnly:Bool = true; // this is for when you don't wanna record at all


	private var _numPlayers = 2;
	private var _twoPlayers:FlxText;
	private var _threePlayers:FlxText;
	private var _fourPlayers:FlxText;

	// Hack to get dpad working for selections
	private var _prvDpadLefts:Bool  = false;
	private var _curDpadLefts:Bool  = false;
	private var _prvDpadRights:Bool = false;
	private var _curDpadRights:Bool = false;

	private var _timer:Float = 0;
	private var _timeLimit:Int = 90;

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();

		FlxG.sound.playMusic("music", 0.35, true);

		// Set a background color
		FlxG.cameras.bgColor = 0xff4a9294;

		_backdropsFar = new Backdrops(this, Reg.BACKDROPSFAR);

		// Create the random buildings
		_buildings = new RandomBuildings(-1, Reg.LEVELLENGTH * 2);
		add(_buildings);

		_p = new Player(240,60,0,null,null,null);
		_p.autoscrollMonkey = true;
		_p2 = new Player(140,-50,1,null,null,null);
		_p2.autoscrollMonkey = true;
		_p3 = new Player(100,-100,2,null,null,null);
		_p3.autoscrollMonkey = true;
		_p4 = new Player(80,20,3,null,null,null);
		_p4.autoscrollMonkey = true;
		add(_p4);
		add(_p3);
		add(_p2);
		add(_p);

		_backdropsMid = new Backdrops(this, Reg.BACKDROPSMID);

		_weatherEmitter = new FlxEmitter(-240,0,200);
		_weatherEmitter.setSize(720,FlxG.height);
		_weatherEmitter.makeParticles(Reg.PARTICLE,200,0,true,0);
		_weatherEmitter.setXSpeed(-80,-10); // 10-100 looks good - try it in ruins?
		_weatherEmitter.setYSpeed(-150,-50);
		_weatherEmitter.setAlpha(0,1,0,1);
		_weatherEmitter.setRotation(-100,100);
		_weatherEmitter.start(false,10,0.007125);
		add(_weatherEmitter);
		
		_backdropsNear = new Backdrops(this, Reg.BACKDROPSNEAR);

        var title = new FlxText(0, 80, FlxG.width, "CONCRETE JUNGLE");
        title.size = 40;
        title.color = 0xff111112;
        title.alignment = "center";
        add(title);
        title.scrollFactor.x = 0;

        choosePlayers = new FlxText(0, FlxG.height/2 + 50, FlxG.width, "Choose Number of Players");
        choosePlayers.alignment = "center";
        choosePlayers.color = 0xff111112;
        add(choosePlayers);
        choosePlayers.scrollFactor.x = 0;

        // Three is centered -- other two are spread
        var textSpread = 40;

        _threePlayers = new FlxText(0, FlxG.height/2 + 10, FlxG.width, "3");
        _threePlayers.size = 32;
        _threePlayers.alignment = "center";
        _threePlayers.scrollFactor.x = 0;
        add(_threePlayers);

        _twoPlayers = new FlxText(-textSpread, FlxG.height/2 + 10, FlxG.width, "2");
        _twoPlayers.size = 32;
        _twoPlayers.scrollFactor.x = 0;
        _twoPlayers.alignment = "center";
        add(_twoPlayers);

        _fourPlayers = new FlxText(textSpread, FlxG.height/2 + 10, FlxG.width, "4");
        _fourPlayers.size = 32;
        _fourPlayers.scrollFactor.x = 0;
        _fourPlayers.alignment = "center";
        add(_fourPlayers);

        names = new FlxText(0,FlxG.height - 16,FlxG.width,"Ian Clarkson   +   Steven Circuiton   +   Colin Marjoram");
        names.color = 0xffffffff;
        names.size = 8;
        names.scrollFactor.x = 0;
        names.alignment = "center";
        add(names);

        FlxG.camera.flash(0xff111112,2.5);

		FlxG.camera.setBounds(0,0, Reg.LEVELLENGTH * 2, FlxG.height);
		FlxG.camera.follow(_p,FlxCamera.STYLE_PLATFORMER,new FlxPoint(50,0),4);

		if (!playbackOnly)
		{
			if (!recording && !replaying)
			{
				startRecord();
			}
			
			if (recording) 
			{
				choosePlayers.text = "RECORDING";
			}
		}
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		FlxG.worldBounds.set(FlxG.camera.scroll.x - 20, FlxG.camera.scroll.y - 20, FlxG.width + 20, FlxG.height + 20);

		super.update();

		_timer += FlxG.elapsed;
		if (_timer > _timeLimit)
		{
			_timer = 0;
			resetState();
		}

		FlxG.camera.scroll.x += 3;

		_weatherEmitter.x = FlxG.camera.scroll.x;

		_curDpadLefts  = isDpadPressed(Input.LEFT);
		_curDpadRights = isDpadPressed(Input.RIGHT);

		var dpadLeftJustPressed = _curDpadLefts && !_prvDpadLefts;
		var dpadRightJustPressed = _curDpadRights  && !_prvDpadRights;

		if (isJustPressing(Input.LEFT) || dpadLeftJustPressed) 
		{
			_numPlayers = _numPlayers > 2 ? _numPlayers - 1 : Reg.MAX_PLAYERS;
		}
		else if (isJustPressing(Input.RIGHT) || dpadRightJustPressed) 
		{
			_numPlayers = _numPlayers < Reg.MAX_PLAYERS ? _numPlayers + 1 : 2;
		}

        _twoPlayers.color   = _numPlayers == 2 ? 0xffffffff : 0xff111112;
        _threePlayers.color = _numPlayers == 3 ? 0xffffffff : 0xff111112;
        _fourPlayers.color  = _numPlayers == 4 ? 0xffffffff : 0xff111112;

        // START THE GAME!
		if (isJustPressing(Input.JUMP) || isJustPressing(Input.ACTION1) || isJustPressing(Input.ACTION2) || isJustPressing(Input.ACTION3))
		{
			onSelectionMade();	
		}

		FlxG.collide(_p, _buildings);
		FlxG.collide(_p2, _buildings);
		FlxG.collide(_p3, _buildings);
		FlxG.collide(_p4, _buildings);

		_prvDpadLefts  = _curDpadLefts;
		_prvDpadRights = _curDpadRights;
	}	

	private function onSelectionMade():Void
	{
		FlxG.cameras.fade(0xffffffff, 2, false, onDemoFaded);
	}
	
	private function onDemoFaded():Void
	{
		FlxG.switchState(new PlayState(_numPlayers));	
	}

	private function resetState():Void
	{
		FlxG.cameras.fade(0xff111112, 2, false, onResetFaded);	
	}

	private function onResetFaded():Void
	{
		FlxG.resetState();
	}

	private function startRecord():Void 
	{
		recording = true;
		replaying = false;

		/**
		 *Note FlxG.recordReplay will restart the game or state
		 *This function will trigger a flag in FlxGame
		 *and let the internal FlxReplay to record input on every frame
		 */
		FlxG.vcr.startRecording(false);
	}

	private function startPlay():Void 
	{
		replaying = true;
		recording = false;

		/**
		 * Here we get a string from stopRecoding()
		 * which records all the input during recording
		 * Then we load the save
		 */

		var save:String = FlxG.vcr.stopRecording();
		/**
		 * NOTE "ANY" or other key wont work under debug mode!
		 */
		FlxG.vcr.loadReplay(save, new MenuState(), ["ANY", "MOUSE"], 0, startRecord);
	}

	private function isDpadPressed(Action:Int):Bool
	{
		if (Action == Input.LEFT)
		{
			for (gp in FlxG.gamepads.getActiveGamepads())
			{
				if (gp.dpadLeft)
				{
					return true;
				}
			}			
			if (FlxG.keys.anyJustPressed(["LEFT"]))
			{
				return true;
			}
		}
		else if (Action == Input.RIGHT)
		{
			for (gp in FlxG.gamepads.getActiveGamepads())
			{
				if (gp.dpadRight)
				{
					return true;
				}
			}
			if (FlxG.keys.anyJustPressed(["RIGHT"]))
			{
				return true;
			}
		}
		return false;
	}

	private function isJustPressing(Action:Int):Bool
	{
		if (Action == Input.LEFT)
		{
			return FlxG.keys.anyJustPressed(["LEFT"]);
		}
		else if (Action == Input.RIGHT)
		{
			return FlxG.keys.anyJustPressed(["RIGHT"]);
		}
		else if (Action == Input.JUMP || Action == Input.ACTION1 || Action == Input.ACTION2 || Action == Input.ACTION3)
		{
			if (FlxG.gamepads.anyJustPressed(PS4ButtonID.X_BUTTON) 
				|| FlxG.gamepads.anyJustPressed(PS4ButtonID.SQUARE_BUTTON)
				|| FlxG.gamepads.anyJustPressed(PS4ButtonID.TRIANGLE_BUTTON)
				|| FlxG.gamepads.anyJustPressed(PS4ButtonID.CIRCLE_BUTTON))
			{
				return true;
			}

			return FlxG.keys.anyJustPressed(["SPACE", "ENTER"]);	
		}

		return false;
	}
}