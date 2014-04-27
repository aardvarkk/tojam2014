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

	private var _cloudsFar:FlxBackdrop;
	private var _cloudsMid:FlxBackdrop;
	private var _cloudsNear:FlxBackdrop;
	private var _mountainsFar:FlxBackdrop;
	private var _buildingsMid:FlxBackdrop;
	private var _buildingsNear:FlxBackdrop;
	private var _foreground:FlxBackdrop;
	private var _mist:FlxBackdrop;
	private var _mist2:FlxBackdrop;
	private var _weatherEmitter:FlxEmitter;
	private var _buildings:RandomBuildings;
	private var _p:Player;
	private var _replay:FlxReplay;
	public static var choosePlayers:FlxText;

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

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();

		FlxG.sound.playMusic("music", 0.35, true);

		// Set a background color
		FlxG.cameras.bgColor = 0xff4a9294;

		_cloudsFar = new FlxBackdrop(Reg.CLOUDSFAR,0.125,0,true,false);
		_cloudsMid = new FlxBackdrop(Reg.CLOUDSMID,0.25,0,true,false);
		_cloudsNear = new FlxBackdrop(Reg.CLOUDSNEAR,0.5,0,true,false);
		_mountainsFar = new FlxBackdrop(Reg.MOUNTAINSFAR,0.1,0,true,false);
		_buildingsMid = new FlxBackdrop(Reg.BUILDINGSMID,0.2,0,true,false);
		_mist = new FlxBackdrop(Reg.MIST,0.45,0,true,false);
		_buildingsNear = new FlxBackdrop(Reg.BUILDINGSNEAR,0.4,0,true,false); 
		_mist2 = new FlxBackdrop(Reg.MIST2,1.15,0,true,false);
		_foreground = new FlxBackdrop(Reg.JUNGLEFOLIAGE,1.3,0,true,false);
		
		_mountainsFar.y = FlxG.height - 180;
		_buildingsMid.y = FlxG.height - 128;
		_buildingsNear.y = FlxG.height - 80;
		_mist.y = FlxG.height - 138; // actually 128 though
		_mist2.y = FlxG.height - 98; // actually 128 though

		_weatherEmitter = new FlxEmitter(-240,0,200);
		_weatherEmitter.setSize(720,FlxG.height);
		_weatherEmitter.makeParticles(Reg.PARTICLE,200,0,true,0);
		_weatherEmitter.setXSpeed(-80,-10); // 10-100 looks good - try it in ruins?
		_weatherEmitter.setYSpeed(-150,-50);
		_weatherEmitter.setAlpha(0,1,0,1);
		_weatherEmitter.setRotation(-100,100);
		_weatherEmitter.start(false,10,0.007125);

		add(_cloudsFar);
		add(_mountainsFar);
		add(_cloudsMid);
		add(_buildingsMid);
		add(_mist);
		add(_cloudsNear);
		add(_buildingsNear);

		// Create the random buildings
		_buildings = new RandomBuildings(
			Reg.DEMOSEED,
			Reg.LEVELLENGTH, 
			FlxG.height, 
			2,
			10,
			1,
			5,
			3
			);
		add(_buildings);

		_p = new Player(240,1,0,null,null,null);
		_p.selected = true;
		add(_p);

		add(_mist2);
		add(_weatherEmitter);
		add(_foreground);


        var title = new FlxText(0, 80, FlxG.width, "CONCRETE JUNGLE");
        title.size = 40;
        title.color = 0xff111112;
        title.alignment = "center";
        add(title);
        title.scrollFactor.x = 0;

        choosePlayers = new FlxText(0, FlxG.height/2 + 50, FlxG.width, "Press Any Button...");
        choosePlayers.alignment = "center";
        choosePlayers.color = 0xff111112;
        add(choosePlayers);
        choosePlayers.scrollFactor.x = 0;

        // Three is centered -- other two are spread
        var textSpread = 40;

        _threePlayers = new FlxText(0, FlxG.height/2 + 10, FlxG.width, "3");
        _threePlayers.color = _numPlayers == 3 ? 0xffffffff : 0xff111112;
        _threePlayers.size = 32;
        _threePlayers.alignment = "center";
        add(_threePlayers);

        _twoPlayers = new FlxText(-textSpread, FlxG.height/2 + 10, FlxG.width, "2");
        _twoPlayers.color = _numPlayers == 2 ? 0xffffffff : 0xff111112;
        _twoPlayers.size = 32;
        _twoPlayers.alignment = "center";
        add(_twoPlayers);

        _fourPlayers = new FlxText(textSpread, FlxG.height/2 + 10, FlxG.width, "4");
        _fourPlayers.color = _numPlayers == 4 ? 0xffffffff : 0xff111112;
        _fourPlayers.size = 32;
        _fourPlayers.alignment = "center";
        add(_fourPlayers);

        FlxG.camera.flash(0xff111112,2.5);

		FlxG.camera.setBounds(0,0, Reg.LEVELLENGTH, FlxG.height);
		FlxG.camera.follow(_p,FlxCamera.STYLE_PLATFORMER,new FlxPoint(50,0),4);

		if (!playbackOnly)
		{
			if (!recording && !replaying)
			{
				startRecord();
			}
			
			if (recording) 
			{
				_p.selected = true;
				choosePlayers.text = "RECORDING";
			}
		}
		
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	public static function pressedStart():Void
	{
		choosePlayers.text = "Number of Players";
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		FlxG.worldBounds.set(FlxG.camera.scroll.x - 20, FlxG.camera.scroll.y - 20, FlxG.width + 20, FlxG.height + 20);

		super.update();

		_curDpadLefts  = isDpadPressed(FlxObject.LEFT);
		_curDpadRights = isDpadPressed(FlxObject.RIGHT);

		var dpadLeftJustPressed = _curDpadLefts && !_prvDpadLefts;
		var dpadRightJustPressed = _curDpadRights  && !_prvDpadRights;

		if (isJustPressing(FlxObject.LEFT) || dpadLeftJustPressed) 
		{
			_numPlayers = _numPlayers > 2 ? _numPlayers - 1 : 4;
		}
		else if (isJustPressing(FlxObject.RIGHT) || dpadRightJustPressed) 
		{
			_numPlayers = _numPlayers < 4 ? _numPlayers + 1 : 2;
		}

        _twoPlayers.color   = _numPlayers == 2 ? 0xffffffff : 0xff111112;
        _threePlayers.color = _numPlayers == 3 ? 0xffffffff : 0xff111112;
        _fourPlayers.color  = _numPlayers == 4 ? 0xffffffff : 0xff111112;

        // START THE GAME!
		if (isJustPressing(Reg.JUMP) || isJustPressing(Reg.KEY1) || isJustPressing(Reg.KEY2) || isJustPressing(Reg.KEY3))
		{
			onSelectionMade();	
		}

		FlxG.collide(_p, _buildings);

		_prvDpadLefts  = _curDpadLefts;
		_prvDpadRights = _curDpadRights;
	}	

	private function onSelectionMade():Void
	{
		FlxG.cameras.fade(0xffffffff, 2, false, onDemoFaded);
	}
	
	/**
	 * Finally, we have another function called by FlxG.fade(), this time
	 * in relation to the callback above.  It stops the replay, and resets the game
	 * once the gameplay demo has faded out.
	 */
	private function onDemoFaded():Void
	{
		FlxG.switchState(new PlayState(_numPlayers));	
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

	private function isDpadPressed(Direction:Int):Bool
	{
		if (Direction == FlxObject.LEFT)
		{
			for (gp in FlxG.gamepads.getActiveGamepads())
			{
				if (gp.dpadLeft)
				{
					return true;
				}
			}			
		}
		else if (Direction == FlxObject.RIGHT)
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

	private function isJustPressing(Direction:Int):Bool
	{
		if (Direction == FlxObject.LEFT)
		{
			return FlxG.keys.anyJustPressed(["LEFT"]);
		}
		else if (Direction == FlxObject.RIGHT)
		{
			return FlxG.keys.anyJustPressed(["RIGHT"]);
		}
		else if (Direction == Reg.JUMP || Direction == Reg.KEY1 || Direction == Reg.KEY2 || Direction == Reg.KEY3)
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