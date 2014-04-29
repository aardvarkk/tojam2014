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
import flixel.input.gamepad.FlxGamepadManager;

import flixel.util.FlxRandom;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	public var explosions:FlxTypedGroup<Explosion>;
	public var bananapops:FlxTypedGroup<Bananapop>;
	public var stinkbombs:FlxTypedGroup<Stinkbomb>;
	public var _bombs:FlxTypedGroup<Bomb>;
	public var _boomerangs:FlxTypedGroup<Boomerang>;
	public var _missiles:FlxTypedGroup<Missile>;
	public static var currentlySelectedPlayer:Int;

	private var _cloudsFar:FlxBackdrop;
	private var _cloudsMid:FlxBackdrop;
	private var _cloudsNear:FlxBackdrop;
	private var _mountainsFar:FlxBackdrop;
	private var _buildingsMid:FlxBackdrop;
	private var _buildingsNear:FlxBackdrop;
	private var _foreground:FlxBackdrop;
	private var _foreground2:FlxBackdrop;
	private var _mist:FlxBackdrop;
	private var _mist2:FlxBackdrop;
	private var _weatherEmitter:FlxEmitter;
	private var _infoText:FlxText;
	private var _players:FlxTypedGroup<Player> = new FlxTypedGroup<Player>();
	private var _bubbles:FlxTypedGroup<Bubble>;
	private var _beams:FlxTypedGroup<Beam>;
	private var _buildings:RandomBuildings;
	private var _racer:Racer;
	private var _camera:FlxCamera;
	private var _numPlayers:Int;
	private var _round:Int;
	private var _selectedPlayer:Int = 0;
	private var _rider:Player;
	private var _roundOver:Bool = false;
	private var _cartScoreTimer:FlxTimer;
	private var _respawnPlayerTimer:FlxTimer;
	private var _crosshair:Crosshair;
	private var _scoreSprites:Array<FlxSprite> = new Array<FlxSprite>();

	public function new(NumPlayers:Int = 2, ?Round:Int = 0)
	{
		super();
		
		// Start as the selected player
		if (Reg.SinglePlayerDebug) {
			currentlySelectedPlayer = Round; 
		}

		_numPlayers = NumPlayers;
		startRound(Round);
	}

	public function accumulateCartScore(Timer:FlxTimer)
	{
		if (!_roundOver) {
			Reg.scores[_rider.number] += 25;
		}
	}

	public function respawnPlayer(P:Player):Void
	{
		P.respawn(_camera.scroll.x + 48, 48);
	}

	public function startRound(Round:Int)
	{
		_round = Round;
		FlxG.log.add('Starting game round $_round with $_numPlayers players');

		if (_round == 0) 
		{
			Reg.resetScores();
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
		super.create();

		#if debug
		FlxG.game.debugger.stats.visible = true;
		#end

		//FlxG.mouse.visible = false;

		_camera = FlxG.camera;
		FlxG.camera.setBounds(0,0, Reg.LEVELLENGTH, FlxG.height);

		FlxG.cameras.bgColor = 0xff4a9294;

		// WHERE I LEFT OFF - For autoscrolling backgrounds, for now, the best solution
		// is probably to just make an animated thing manually
		// and in other situations, we'll try having a camera just for the background
		// since we don't want the split screen cameras to fuck it up

		// Initialize things
		//_background = new FlxBackdrop(Reg.BACKGROUND,0.0675,0,true, false);
		_cloudsFar = new FlxBackdrop(Reg.CLOUDSFAR,0.125,0,true,false);
		_cloudsMid = new FlxBackdrop(Reg.CLOUDSMID,0.25,0,true,false);
		_cloudsNear = new FlxBackdrop(Reg.CLOUDSNEAR,0.5,0,true,false);
		_mountainsFar = new FlxBackdrop(Reg.MOUNTAINSFAR,0.1,0,true,false);
		_buildingsMid = new FlxBackdrop(Reg.BUILDINGSMID,0.2,0,true,false);
		_mist = new FlxBackdrop(Reg.MIST,0.45,0,true,false);
		_buildingsNear = new FlxBackdrop(Reg.BUILDINGSNEAR,0.4,0,true,false); 
		_mist2 = new FlxBackdrop(Reg.MIST2,1.15,0,true,false);
		_foreground = new FlxBackdrop(Reg.JUNGLEFOLIAGE,1.3,0,true,false);
		_foreground2 = new FlxBackdrop(Reg.JUNGLEFOLIAGE2,1.3,0,true,false);
		
		_mountainsFar.y = FlxG.height - 180;
		_buildingsMid.y = FlxG.height - 128;
		_buildingsNear.y = FlxG.height - 80;
		_mist.y = FlxG.height - 138; // actually 128 though
		_mist2.y = FlxG.height - 98; // actually 128 though
		_foreground2.y = FlxG.height - 48;

		_weatherEmitter = new FlxEmitter(-240,0,200);
		_weatherEmitter.setSize(720,FlxG.height);
		_weatherEmitter.makeParticles(Reg.PARTICLE,200,0,true,0);
		_weatherEmitter.setXSpeed(-150,-50); // 10-100 looks good - try it in ruins?
		_weatherEmitter.setYSpeed(-150,-50);
		_weatherEmitter.setAlpha(0,1,0,1);
		_weatherEmitter.setRotation(-100,100);
		_weatherEmitter.start(false,10,0.007125);

		explosions = new FlxTypedGroup();
		bananapops = new FlxTypedGroup();
		stinkbombs = new FlxTypedGroup();
		_bombs = new FlxTypedGroup();
		_missiles = new FlxTypedGroup();
		_boomerangs = new FlxTypedGroup();

		_bubbles = new FlxTypedGroup();
		_beams = new FlxTypedGroup();
		_crosshair = new Crosshair();
		
		for (a in 0...5)
		{
			_bombs.add(new Bomb());
			_boomerangs.add(new Boomerang());
			_missiles.add(new Missile());
			explosions.add(new Explosion());
			bananapops.add(new Bananapop());
			stinkbombs.add(new Stinkbomb());
		}

		_infoText = new FlxText(10,10, FlxG.width - 20, null);
		_infoText.size = 8;

		_racer = new Racer(FlxG.width - Reg.RACERWIDTH, FlxG.height - Reg.RACERHEIGHT - 100);
		_racer.drag.y = 300;

		// Add objects to game from back to front
		//add(_background);
		add(_cloudsFar);
		add(_mountainsFar);
		add(_cloudsMid);
		add(_buildingsMid);
		add(_mist);
		add(_cloudsNear);
		add(_buildingsNear);

		// Create the random buildings
		_buildings = new RandomBuildings(
			-1,
			Reg.LEVELLENGTH, 
			FlxG.height, 
			2,
			10,
			1,
			5,
			3
			);
		add(_buildings);

		add(_racer);

		// Add players in reverse order so 0th shows on top
		// And mount the player whose turn it is
		var p = _numPlayers;
		while (--p >= 0) {
			var player = new Player(150, 100, p, _bombs, _boomerangs, _missiles);
			_players.add(player);
			_bubbles.add(player.bubble);
			_beams.add(player.beam);

			if (p == _round) {
				player.mount(_racer, _crosshair);
				_rider = player;
			}
		}
		add(_players);
		
		add(_bubbles);
		add(_beams);
		add(_bombs);
		add(_boomerangs);
		add(_missiles);

		add(_mist2);

		add(bananapops);
		add(explosions);
		add(stinkbombs);

		add(_crosshair);

		add(_weatherEmitter);

		add(_foreground);
		add(_foreground2);

		// Info text and score sprites
		add(_infoText);
		_infoText.scrollFactor.x = 0;
		_infoText.scrollFactor.y = 0;
		_infoText.color = 0xffffffff;

		for (i in 0..._numPlayers) {
			_scoreSprites.push(new FlxSprite());
			_scoreSprites[i].loadGraphic(Reg.MONKEYS[i], true, 16, 16);
			_scoreSprites[i].scrollFactor.x = 0;
			_scoreSprites[i].visible = false;
			add(_scoreSprites[i]);
		}

		FlxG.camera.flash(0xffffffff,0.25);
		FlxG.camera.setBounds(0,0, Reg.LEVELLENGTH, FlxG.height);

		// Keep track of scores for players
		_cartScoreTimer = new FlxTimer(1, accumulateCartScore, 0);

        FlxG.sound.play("Ambient Jungle", 0.4, true);
	}
	
	public function drawScores(X:Int, Y:Int)
	{
		var lineAdd = 11;
		for (i in 0..._numPlayers)
		{
			// trace('$i to $X ${Y + (i * lineAdd)}');
			_scoreSprites[i].x = X;
			_scoreSprites[i].y = Y + (i * lineAdd);
			_scoreSprites[i].visible = true;
		}
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		// trace(FlxG.gamepads.getActiveGamepadIDs());
		// trace(FlxG.gamepads.anyButton());
		// for (gp in FlxG.gamepads.getActiveGamepads()) {
		// 	for (button in gp.buttons) {
		// 		if (button != null && button.id != null)
		// 		{
		// 			trace('gp with id ${gp.id} has button $button');
		// 		}
		// 	}
		// 	// trace('${gp.dpadUp}');
		// 	// trace('${gp.hat}');
		// 	// trace('${gp.ball}');
		// }

		// Update player score strings visually
		_infoText.text = 'Round: ${_round + 1} of ${_numPlayers}\n';
		_infoText.text += 'Remaining: ${Math.max(0, Math.round(Reg.LEVELLENGTH - _racer.x - _racer.width))}m\n';
		_infoText.text += Reg.getScoreString();
		drawScores(9, 28);

		// Game actively playing
		if (!_roundOver) 
		{
			// Slide camera to follow racer
			_camera.scroll.x += Reg.RACERSPEED * FlxG.elapsed;
			_weatherEmitter.x = _camera.scroll.x;

			// Resize the world - collisions are only detected within the world bounds
			FlxG.worldBounds.set(FlxG.camera.scroll.x - 20, FlxG.camera.scroll.y - 20, FlxG.width + 20, FlxG.height + 20);
			
			// Collisions
			//FlxG.collide(_players, _buildings);
			FlxG.overlap(_players, _racer, swap);
			FlxG.collide(_players, _players);

			for (b in _bombs)
			{
				if (b.velocity.y >= 0)
				{
					FlxG.collide(b, _buildings, bombBounce);
				}
			}

			// Overlap

			// off-screen kill
			for (p in _players)
			{
				if (p.alive == false)
				{
					p.deathTimer -= FlxG.elapsed;
					if (p.deathTimer < 0)
						respawnPlayer(p);
				}
				if (p.alive == true && (p.y > FlxG.height + 20 || p.x + p.width < _camera.scroll.x - 20))
				{
					p.kill();
					Reg.scores[p.number] -= 100;
				}
				if (p.diving == false)
				{
					FlxG.collide(p, _buildings);
				}
				if (p != _rider)
				{
					FlxG.overlap(p, _bombs, explodeOnPlayer);
					FlxG.overlap(p, _boomerangs, splatOnPlayer);
					FlxG.overlap(p, _missiles, stankOnPlayer);
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
			// _infoText.text = Reg.getScoreString();
			new FlxTimer(2, endRoundTimer);
		}

		// Game controls
		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(new MenuState());
		}
		if (Reg.SinglePlayerDebug) // SinglePlayerDebug controls
		{
			if (FlxG.keys.justPressed.SPACE)
			{
				selectNextPlayer();
			}
			if (FlxG.keys.justPressed.Q)
			{
				for (p in _players)
				{
					if (p != _players.members[currentlySelectedPlayer])
					{
						p.autoscrollMonkey = true;
					}
				}
			}
		}
		// Super
		super.update();
	}

	public function selectNextPlayer():Void
	{
		currentlySelectedPlayer = currentlySelectedPlayer < _numPlayers - 1 ? currentlySelectedPlayer + 1 : 0;
		FlxG.log.add('Player $currentlySelectedPlayer is currently selected');
	}

	public function bombBounce(B:Bomb, R:Building):Void
	{
		if (B.isTouching(FlxObject.FLOOR))
		{
			FlxG.log.add("Bomb hit floor");
			B.velocity.y = -75;
		}
		else if (B.isTouching(FlxObject.LEFT))
		{
			FlxG.log.add("Bomb hit wall");
			B.velocity.x = 50;
		}
		else if (B.isTouching(FlxObject.RIGHT))
		{
			FlxG.log.add("Bomb hit wall");
			B.velocity.x = -50;
		}
		FlxG.sound.play("BombBounce", 0.25);
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
		P.mount(R, _crosshair);
		Reg.scores[P.number] += 500;
	}	

	public function explodeOnPlayer(P:Player, R:FlxSprite):Void
	{
		P.velocity.x += R.velocity.x * 2;
		P.velocity.y += R.velocity.y * 2;
		explosions.recycle(Explosion,[],true,false).boom(R, R.velocity.x/4, R.velocity.y/4);
		R.kill();
		if (FlxRandom.intRanged(0,4) == 0)
		{
			FlxG.sound.play("Megascreech1", 0.15);
		}
	}

	public function splatOnPlayer(P:Player, R:FlxSprite):Void
	{
		P.velocity.x += R.velocity.x * 2;
		P.velocity.y += R.velocity.y * 2;
		bananapops.recycle(Bananapop,[],true,false).boom(R, R.velocity.x/4, R.velocity.y/4);
		R.kill();
		if (FlxRandom.intRanged(0,4) == 0)
		{
			FlxG.sound.play("Screech1", 0.15);
		}
	}

	public function stankOnPlayer(P:Player, R:FlxSprite):Void
	{
		P.velocity.x += R.velocity.x * 2;
		P.velocity.y += R.velocity.y * 2;
		stinkbombs.recycle(Stinkbomb,[],true,false).boom(R, R.velocity.x/4, R.velocity.y/4);
		R.kill();
		if (FlxRandom.intRanged(0,4) == 0)
		{
			FlxG.sound.play("Megascreech2", 0.15);
		}
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