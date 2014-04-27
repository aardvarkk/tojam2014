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

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	// Variables live here
	//private var _background:FlxBackdrop;
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
	private var _infoText:FlxText;
	private var _players:FlxTypedGroup<Player>;
	private var _bubbles:FlxTypedGroup<Bubble>;
	private var _beams:FlxTypedGroup<Beam>;
	public var explosions:FlxTypedGroup<Explosion>;
	public var bananapops:FlxTypedGroup<Bananapop>;
	public var stinkbombs:FlxTypedGroup<Stinkbomb>;
	public var _bombs:FlxTypedGroup<Bomb>;
	public var _boomerangs:FlxTypedGroup<Boomerang>;
	public var _missiles:FlxTypedGroup<Missile>;
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
	//private var _bombs:FlxTypedGroup<Bomb>;
	private var _roundOver:Bool = false;
	private var _cartScoreTimer:FlxTimer;
	private var _respawnPlayerTimer:FlxTimer;
	private var _crosshair:Crosshair;

	private var _monkeyScoreSprites:Array<FlxSprite> = new Array<FlxSprite>();

	public function new(NumPlayers:Int = 2, ?Round:Int = 0)
	{
		super();
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
		#if debug
		FlxG.game.debugger.stats.visible = true;
		#end

		//FlxG.mouse.visible = false;

		_camera = FlxG.camera;
		FlxG.camera.setBounds(0,0, Reg.LEVELLENGTH, FlxG.height);

		FlxG.cameras.bgColor = 0xff4a9294;

		if (FlxG.sound.music != null)
		{
			//FlxG.sound.music.stop();
		}

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
		
		_mountainsFar.y = FlxG.height - 180;
		_buildingsMid.y = FlxG.height - 128;
		_buildingsNear.y = FlxG.height - 80;
		_mist.y = FlxG.height - 138; // actually 128 though
		_mist2.y = FlxG.height - 98; // actually 128 though

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
		_players = new FlxTypedGroup();

		_p1 = new Player(150,100,0, _bombs, _boomerangs, _missiles);

		var scoreP1 = new FlxSprite();
		scoreP1.loadGraphic(Reg.MONKEY1, true, 16, 16);
		scoreP1.scrollFactor.x = 0;
		_monkeyScoreSprites.push(scoreP1);

		_p2 = new Player(150,100,1, _bombs, _boomerangs, _missiles);
		var scoreP2 = new FlxSprite();
		scoreP2.loadGraphic(Reg.MONKEY2, true, 16, 16);
		scoreP2.scrollFactor.x = 0;
		_monkeyScoreSprites.push(scoreP2);
		
		if (_numPlayers >= 3)
		{
			_p3 = new Player(150,100,2, _bombs, _boomerangs, _missiles);
			var scoreP3 = new FlxSprite();
			scoreP3.loadGraphic(Reg.MONKEY3, true, 16, 16);
			scoreP3.scrollFactor.x = 0;
			scoreP3.visible = false;
			_monkeyScoreSprites.push(scoreP3);
		}

		if (_numPlayers == 4)
		{
			_p4 = new Player(150,100,3, _bombs, _boomerangs, _missiles);
			var scoreP4 = new FlxSprite();
			scoreP4.loadGraphic(Reg.MONKEY4, true, 16, 16);
			scoreP4.scrollFactor.x = 0;
			scoreP4.visible = false;
			_monkeyScoreSprites.push(scoreP4);
		}

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
			null,
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
			_beams.add(_p4.beam);
		}
		if (_numPlayers >= 3)
		{
			_players.add(_p3);
			_bubbles.add(_p3.bubble);
			_beams.add(_p3.beam);
		}
		if (_numPlayers >= 2)
		{
			_players.add(_p2);
			_bubbles.add(_p2.bubble);
			_beams.add(_p2.beam);
		}
		_players.add(_p1);
		_bubbles.add(_p1.bubble);
		_beams.add(_p1.beam);

		// mount the player whose turn it is?
		for (p in _players)
		{
			if (p.number == _round)
			{
				p.mount(_racer, _crosshair);
				_rider = p;
			}
		}

		add(_racer);
		
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

		for (ms in _monkeyScoreSprites) 
		{
			add(ms);
		}

		add(_infoText);
		_infoText.scrollFactor.x = 0;
		_infoText.scrollFactor.y = 0;
		_infoText.color = 0xffffffff;

		// The last stuff
		//FlxG.sound.play("");
		FlxG.camera.flash(0xffffffff,0.25);

		FlxG.camera.setBounds(0,0, Reg.LEVELLENGTH, FlxG.height);

		// Watchlist
		// FlxG.watch.add(this, "_numPlayers", "Players");
		// FlxG.watch.add(this, "_round", "Round");
		// FlxG.watch.add(_p1, "ridingVehicle", "P1 Riding");
		// FlxG.watch.add(_p2, "ridingVehicle", "P2 Riding");
		// FlxG.watch.add(_p3, "ridingVehicle", "P3 Riding");
		// FlxG.watch.add(_p4, "ridingVehicle", "P4 Riding");

		// Keep track of scores for players
		_cartScoreTimer = new FlxTimer(1, accumulateCartScore, 0);

        FlxG.sound.play("Ambient Jungle", 0.4, true);


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

	public function drawScores(X:Int, Y:Int)
	{
		var lineAdd = 11;
		for (i in 0..._numPlayers)
		{
			trace('$i to $X ${Y + (i * lineAdd)}');
			_monkeyScoreSprites[i].x = X;
			_monkeyScoreSprites[i].y = Y + (i * lineAdd);
			_monkeyScoreSprites[i].visible = true;
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
		FlxG.sound.play("Megascreech1", 0.15);
	}

	public function splatOnPlayer(P:Player, R:FlxSprite):Void
	{
		P.velocity.x += R.velocity.x * 2;
		P.velocity.y += R.velocity.y * 2;
		bananapops.recycle(Bananapop,[],true,false).boom(R, R.velocity.x/4, R.velocity.y/4);
		R.kill();
		FlxG.sound.play("Screech1", 0.15);
	}

	public function stankOnPlayer(P:Player, R:FlxSprite):Void
	{
		P.velocity.x += R.velocity.x * 2;
		P.velocity.y += R.velocity.y * 2;
		stinkbombs.recycle(Stinkbomb,[],true,false).boom(R, R.velocity.x/4, R.velocity.y/4);
		R.kill();
		FlxG.sound.play("Megascreech2", 0.15);
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