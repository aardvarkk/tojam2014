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
	private var _roundOver:Bool = false;

	public function new(NumPlayers:Int = 2, ?Round:Int = 0)
	{
		super();
		_numPlayers = NumPlayers;

		startRound(Round);
	}

	public function startRound(Round:Int)
	{
		FlxG.log.add('Starting game round $_round with $_numPlayers players');
		_round = Round;

		if (_round == 0) 
		{
			for (i in 0..._numPlayers)
			{
				Reg.scores[i] = 0;
			}
		}
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
		FlxG.camera.setBounds(0,0, Reg.LEVELLENGTH, FlxG.height);

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

		_infoText = new FlxText(10,10, FlxG.width - 20, null);

		_racer = new Racer(FlxG.width - Reg.RACERWIDTH, FlxG.height - Reg.RACERHEIGHT);
		_racer.drag.y = 300;

		// Add objects to game from back to front
		add(_backdropFar);

		add(_weatherEmitter);

		// Create the random buildings
		_buildings = new RandomBuildings(
			0,
			Reg.LEVELLENGTH, 
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

		// mount the player whose turn it is?
		for (p in _players)
		{
			if (p.number == _round)
			{
				p.mount(_racer);
				_rider = p;
			}
		}

		add(_racer);
		
		add(_players);
		add(_bubbles);

		add(_infoText);
		_infoText.scrollFactor.x = 0;
		_infoText.scrollFactor.y = 0;
		_infoText.color = 0;

		// The last stuff
		//FlxG.sound.play("");
		FlxG.camera.flash(0xffffffff,0.25);

		FlxG.camera.setBounds(0,0, Reg.LEVELLENGTH, FlxG.height);

		// Watchlist
		FlxG.watch.add(this, "_numPlayers", "Players");
		FlxG.watch.add(this, "_round", "Round");
		FlxG.watch.add(_p1, "ridingVehicle", "P1 Riding");
		FlxG.watch.add(_p2, "ridingVehicle", "P2 Riding");
		FlxG.watch.add(_p3, "ridingVehicle", "P3 Riding");
		FlxG.watch.add(_p4, "ridingVehicle", "P4 Riding");

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
		// Game actively playing
		if (!_roundOver) 
		{
			// Slide camera to follow racer
			_camera.scroll.x += Reg.RACERSPEED * FlxG.elapsed;

			// Update player score strings visually
			_infoText.text = Reg.getScoreString();

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
					Reg.scores[p.number] -= 100;
				}
				if (p.diving == false)
				{
					FlxG.collide(p, _buildings);
				}
			}

			// Check for round over
			if (_racer.x + _racer.width >= Reg.LEVELLENGTH)
			{
				endRound();
			}
		}
		// Round is over!
		else 
		{
			_infoText.text = Reg.getScoreString();
			_infoText.text += "\nROUND OVER!";
			new FlxTimer(2, endRoundTimer);
		}

		// Game controls
		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.resetState();
		}
		if (FlxG.keys.justPressed.SPACE)
		{
			_selectedPlayer += 1;
			if (_selectedPlayer > _numPlayers - 1) _selectedPlayer = 0;

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
			Reg.scores[_rider.number] -= 200;
			_rider.dismount();
		}
		// add new rider
		_rider = P;
		P.mount(R);
		Reg.scores[P.number] += 500;
	}	

	public function endRoundTimer(Timer:FlxTimer)
	{
		FlxG.switchState(new PlayState(_numPlayers, _round + 1));
	}

	public function endRound()
	{
		_roundOver = true;

		// Still more rounds to go, so reset everything and switch the racer...
		if (_round < _numPlayers - 1) 
		{

		}
		// Done the game, show which player won!
		else
		{
			FlxG.switchState(new ShowWinnerState());
		}
	}
}