package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.util.FlxRect;

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
	private var _players:FlxTypedGroup<Player>;
	private var _bubbles:FlxTypedGroup<Bubble>;
	private var _p1:Player;
	private var _p2:Player;
	private var _p3:Player;
	private var _p4:Player;
	private var _buildings:RandomBuildings;
	private var _racer:Racer;
	private var _camera:FlxCamera;
	private var _numPlayers:Int;
	private var _round:Int;
	private var _selectedPlayer:Int = 0;
	private var _rider:Player;

	public function new(NumPlayers:Int = 4, ?Round:Int = 0)
	{
		super();
		_numPlayers = NumPlayers;
		_round = Round;

		FlxG.log.add('Starting game round $_round with $_numPlayers players');
	}

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		#if debug
		FlxG.game.debugger.stats.visible = true;
		#end

		//FlxG.mouse.visible = false;

		_camera = FlxG.camera;
		//_camera.deadzone = new FlxRect(10, 10, FlxG.width - 10, FlxG.height - 10);

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
		_backdropFar = new FlxBackdrop(Reg.SNOWCLOUDS,0.5,0,true,false);
		
		_weatherEmitter = new FlxEmitter(-240,-5);
		_weatherEmitter.setSize(720,0);
		_weatherEmitter.makeParticles(Reg.PARTICLE,400,0,true,0);
		_weatherEmitter.setXSpeed(-50,-150); // 10-100 looks good - try it in ruins?
		_weatherEmitter.setYSpeed(50,80);
		_weatherEmitter.setAlpha(1,1,0,0.5);
		_weatherEmitter.setRotation(0,0);
		_weatherEmitter.start(false,10,0.007125);

		_players = new FlxTypedGroup();
		_p1 = new Player(150,100,0);
		if (_numPlayers >= 2)
			_p2 = new Player(150,100,1);
		if (_numPlayers >= 3)
			_p3 = new Player(150,100,2);
		if (_numPlayers == 4)
			_p4 = new Player(150,100,3);
		_bubbles = new FlxTypedGroup();

		_infoText = new FlxText(10,10, FlxG.width - 20, "HELLO!");

		// Add objects to game from back to front
		add(_backdropFar);

		add(_weatherEmitter);

		// Create the random buildings
		_buildings = new RandomBuildings(
			0,
			FlxG.width * 10, 
			FlxG.height, 
			2,
			10,
			1,
			5,
			3
			);
		add(_buildings);

		// Add players in reverse order!
		if (_numPlayers == 4)
		{
			_players.add(_p4);
			_bubbles.add(_p4.bubble);
		}
		if (_numPlayers >= 3)
		{
			_players.add(_p3);
			_bubbles.add(_p3.bubble);
		}
		if (_numPlayers >= 2)
		{
			_players.add(_p2);
			_bubbles.add(_p2.bubble);
		}
		_players.add(_p1);
		_bubbles.add(_p1.bubble);
		
		add(_players);
		add(_bubbles);

		// Add racer
		_racer = new Racer(FlxG.width - Reg.RACERWIDTH, FlxG.height - Reg.RACERHEIGHT);
		add(_racer);

		add(_infoText);
		_infoText.scrollFactor.x = 0;
		_infoText.scrollFactor.y = 0;

		// The last stuff
		//FlxG.sound.play("");
		FlxG.camera.flash(0xffffffff,0.25);

		FlxG.camera.setBounds(0,0, FlxG.width * 10, FlxG.height);

		_camera.follow(_racer, FlxCamera.STYLE_LOCKON);
		_camera.followLead.x = -130;

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

		// Resize the world - collisions are only detected within the world bounds
		FlxG.worldBounds.set(FlxG.camera.scroll.x - 20, FlxG.camera.scroll.y - 20, FlxG.width + 20, FlxG.height + 20);
		
		// Collisions
		//FlxG.collide(_players, _buildings);
		FlxG.overlap(_players, _racer, swap);

		// Overlap

		// off-screen kill
		for (p in _players)
		{
			if (p.y > FlxG.height + 20 || p.x + p.width < _camera.scroll.x - 20)
			{
				p.respawn(_camera.scroll.x + 48, 48);
			}
			if (p.diving == false)
			{
				FlxG.collide(p, _buildings);
			}
		}


		// Game controls
		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.resetState();
		}
		if (FlxG.keys.justPressed.SPACE)
		{
			_selectedPlayer += 1;
			if (_selectedPlayer > 3) _selectedPlayer = 0;

			for (p in _players)
			{
				if (p.number == _selectedPlayer)
					p.selected = true;
				else
					p.selected = false;
			}
		}

		// Super
		super.update();
	}

	public function swap(P:Player, R:FlxSprite):Void
	{
		// if the player colliding is the one who's already riding, don't do anything
		if (P == _rider)
			return;
		// kick out old rider if there is one
		if (_rider != null)
		{
			_rider.dismount;
			FlxG.log.add('kicked out $_rider');
		}
		// add new rider
		_rider = P;
		P.mount(R);
		FlxG.log.add('$P is now the new rider');
	}	

	public function endRound()
	{
		// Still more rounds to go, so reset everything and switch the racer...
		if (_round < _numPlayers - 1) 
		{

		}
		// Done the game, show which player won!
		else
		{
			FlxG.switchState(new ShowWinnerState(0));
		}
	}
}