package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import flixel.util.FlxRandom;
import flixel.effects.particles.FlxEmitterExt;
import flixel.addons.display.FlxExtendedSprite;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxRandom;

class Player extends FlxExtendedSprite
{
	public var attacking:Bool = false;
	public var attackTimer:Float = 0;
	public var ATTACKDELAY:Float = 0.5;
	public var autoscrollMonkey:Bool = false;
	public var bubble:Bubble;
	public var beam:Beam;
	public var climbing:Bool = false;
	public var controlSet:Int = 0;
	public var deathTimer:Float = 0;
	public var diving:Bool = false;
	public var gravity:Float = 450;
	public var invulnerable:Bool = false;
	public var number:Int;
	public var ridingVehicle:Bool = false;
	public var selected:Bool = false;

	private var _vehicle:FlxSprite;
	private var jumpTimer:Float;
	private var jumpStrength:Float = 100;
	private var runAccel = 900;
	private var diveBombMaxVelocityMult = 3; // Multiplier to max velocity
	private var diveBombBoostX = 300; // Instant boost to velocity in X
	private var diveBombSetVelY = 100; // Instant set to velocity in Y
	private var jumped:Bool = false;
	private var landed:Bool = false;
	private var _bombs:FlxTypedGroup<Bomb>;
	private var _boomerangs:FlxTypedGroup<Boomerang>;
	private var _missiles:FlxTypedGroup<Missile>;
	private var invTimer:Float = 0.8;
	private var invDuration:Float = 0.8;
	private var respawnTimer:Float = 0;
	private var _aim:Float = 180;
	private var _crosshair:Crosshair;
	private var _jumpStrings = ["LightOoh", "TinyOoh1", "TinyOoh2", "TinyOoh3", "TinyOoh4", "TinyOoh5", "TinyOoh6", "TinyOoh7", "TinyOoh8", "TinyOoh9"];
	private var _deathStrings = ["Megascreech1", "Megascreech2", "Megascreech3", "Squak"];
	private var autoJumpTimer:Float = 0;
	private var autoJumpDelay:Float = 0.1;

	public function new(X:Int, Y:Int, Number:Int, Bombs:FlxTypedGroup<Bomb>, Boomerangs:FlxTypedGroup<Boomerang>, Missiles:FlxTypedGroup<Missile>)
	{
		super(X, Y);

		number = Number;
		_bombs = Bombs; // ref to the bomb group
		_boomerangs = Boomerangs;
		_missiles = Missiles;

		loadGraphic(Reg.MONKEYS[number], true, 16, 16);

		bubble = new Bubble(X, Y);
		beam = new Beam(X, Y);

		width = 10;
		height = 13;
		offset.x = 3;
		offset.y = 3;

		animation.add("idle", [0, 1, 2, 3], 6, true);
		animation.add("walk", [4, 5, 6], 12, true);	
		animation.add("jump", [9, 10, 11, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12], 8, true);
		animation.add("fall", [12], 8, true);
		animation.add("climb", [11, 12], 8, true);
		animation.add("climbidle", [8], 4, true);
		animation.add("attack", [10], 4, false);

		reset(X, Y);
	}

	override public function update():Void
	{
		if (ridingVehicle)
		{
			x = _vehicle.x + 12; // +20 good for 48x16
			y = _vehicle.y; // and -16
			_crosshair.angle = _aim;
			_crosshair.x = x + width / 2;
			_crosshair.y = y + height / 2;
			if (attackTimer > 0)
				attackTimer -= FlxG.elapsed;

			ridingControls();
		}
		else
		{
			movingControls();
		}


		if (autoscrollMonkey)
		{
			acceleration.x = 0;
			acceleration.x += (runAccel * 0.75);
			facing = FlxObject.RIGHT;
			flipX = false;
			if (isTouching(FlxObject.WALL))
				{
					jumpStrength = 300;
					if (autoJumpTimer < 0)
					{
						jump();
						//velocity.x -= 50;
						//velocity.y -= 20;
						autoJumpTimer = autoJumpDelay;
					}
				}
			autoJumpTimer -= FlxG.elapsed;
			if (autoJumpTimer < 0 && isTouching(FlxObject.FLOOR))
			{
				var j = FlxRandom.intRanged(0,9);
				if (j == 9)
				{
					jump();
					autoJumpTimer = autoJumpDelay;
				}
			}
			if (y > FlxG.height)
			{
				y = -50;
				x -= 50;
				FlxG.sound.play("LightOoh");
			}
			if (x > FlxG.camera.scroll.x + FlxG.width || x < FlxG.camera.scroll.x)
			{
				y = -50;
				x = FlxG.camera.scroll.x + 50;
			}

			if (_selected)
				ridingControls();
			else if (autoscrollMonkey)
				cpuMonkeyDefend();
		}
		else
		{
			if (_selected)
				movingControls();
			else if (autoscrollMonkey)
				cpuMonkeyAssault();
		}


		animate();

		// Respawn stuff
		if (respawnTimer > 0) // when it was >= 0 there were bugs
		{
			respawnTimer -= FlxG.elapsed;
			velocity.y = 0;
			bubble.x = x - 10;
			bubble.y = y - 12;

			if (Input.isPressing(Input.JUMP, number) || x > FlxG.camera.scroll.x + 100 || respawnTimer <= 0)
			{
				jumped = true;
				landed = false;
				jumpTimer = -1;
				respawnTimer = -1;
				bubble.die();
			}
		}

		super.update();
	}

	public function cpuMonkeyAssault():Void
	{
		acceleration.x = 0;
		acceleration.x += (runAccel * 0.75);
		facing = FlxObject.RIGHT;
		flipX = false;

		if (isTouching(FlxObject.WALL))
			{
				jumpStrength = 200;
				if (autoJumpTimer < 0)
				{
					jump();
					velocity.x -= 100;
					velocity.y -= 20;
					autoJumpTimer = autoJumpDelay;
				}
			}
		autoJumpTimer -= FlxG.elapsed;
		if (autoJumpTimer < 0 && isTouching(FlxObject.FLOOR))
		{
			var j = FlxRandom.intRanged(0,9);
			if (j == 9)
			{
				jump();
				autoJumpTimer = autoJumpDelay;
			}
		}
		if (y > FlxG.height)
		{
			y = -50;
			x -= 50;
			FlxG.sound.play("LightOoh");
		}
		if (x > FlxG.camera.scroll.x + FlxG.width || x < FlxG.camera.scroll.x)
		{
			y = -50;
			x = FlxG.camera.scroll.x + 50;
		}
	}

	public function cpuMonkeyDefend():Void
	{
		if (attackTimer <= 0)
		{
			_aim = FlxRandom.intRanged(150,220);
			
			var r = FlxRandom.intRanged(0,2);

			if (r == 0)
				_bombs.recycle(Bomb,[],true,false).shoot(this, _aim);
			else if (r == 1)
				_boomerangs.recycle(Boomerang,[],true,false).shoot(this, _aim);
			else
				_missiles.recycle(Missile,[],true,false).shoot(this, _aim);

			attackTimer = ATTACKDELAY;
		}
	}

	public function ridingControls():Void
	{
		var controlNumber = Reg.SinglePlayerMode ? 0 : number;
		if (Reg.SinglePlayerMode && !selected) {
			return;
		}

		_vehicle.acceleration.y = 0;

		if (Input.isPressing(Input.UP, controlNumber) && (_vehicle.y + _vehicle.height/2 > FlxG.height/2))
		{
			_vehicle.acceleration.y -= runAccel * .25;
		}
		else if (Input.isPressing(Input.DOWN, controlNumber) && (_vehicle.y + _vehicle.height < FlxG.height))
		{
			_vehicle.acceleration.y += runAccel * .25;
		}

		if (Input.isPressing(Input.LEFT, controlNumber))
		{
			_aim -= 4;
		}
		else if (Input.isPressing(Input.RIGHT, controlNumber))
		{
			_aim += 4;
		}

		if (_vehicle.y + _vehicle.height/2 < FlxG.height/2)
		{
			_vehicle.velocity.y = 0;
			_vehicle.acceleration.y = 0;
			_vehicle.y = FlxG.height/2 - _vehicle.height/2;
		}
		else if (_vehicle.y + _vehicle.height > FlxG.height)
		{
			_vehicle.velocity.y = 0;
			_vehicle.acceleration.y = 0;
			_vehicle.y = FlxG.height - _vehicle.height;
		}

		if (attackTimer <= 0)
		{
			if (Input.isPressing(Input.ACTION1, controlNumber))
			{
				FlxG.log.add("Shot a bomb!");
				_bombs.recycle(Bomb,[],true,false).shoot(this, _aim);
				attackTimer = ATTACKDELAY;
			}
			else if (Input.isPressing(Input.ACTION2, controlNumber))
			{
				FlxG.log.add("Shot a boomerang!");
				_boomerangs.recycle(Boomerang,[],true,false).shoot(this, _aim);
				attackTimer = ATTACKDELAY;
			}
			else if (Input.isPressing(Input.ACTION3, controlNumber))
			{
				FlxG.log.add("Shot a missile!");
				_missiles.recycle(Missile,[],true,false).shoot(this, _aim);
				attackTimer = ATTACKDELAY;
			}
		}
	}

	public function movingControls():Void
	{
		var controlNumber = Reg.SinglePlayerMode ? 0 : number;
		if (Reg.SinglePlayerMode && !selected) {
			return;
		}

		acceleration.x = 0;

		// Move Left
		if (Input.isPressing(Input.LEFT, controlNumber))
		{
			flipX = true;
			facing = Input.LEFT;
			acceleration.x -= runAccel;
		}
		
		// Move Right
		if (Input.isPressing(Input.RIGHT, controlNumber))
		{
			flipX = false;
			facing = Input.RIGHT;
			acceleration.x += runAccel;
		}
		
		// Jump Reset
		if (isTouching(FlxObject.FLOOR))
		{
			if (landed == false)
			{
				playLandingSound();
				landed = true;
			}
			
			jumped = false; // reset jump press
			jumpTimer = 0;
		}
		else if (isTouching(FlxObject.WALL))
		{
			// WALL JUMP
			climbing = true;
			velocity.y = 30;
			landed = true;
			jumpTimer = 0;
		}
		else if (!isTouching(FlxObject.FLOOR) && !isTouching(FlxObject.WALL))
		{
			landed = false;
		}
		
		// Just hit jump
		// It's either going to trigger a jump or a dive bomb, depending upon whether or not down key is held
		if (Input.isJustPressing(Input.JUMP, controlNumber))
		{
			// Starting dive bomb
			// If not already diving and BOTH trying to start a jump and holding down, start the divebomb
			// Immediately set vertical velocity
			if (!diving && Input.isPressing(Input.DOWN, controlNumber))
			{
				FlxG.sound.play("Divebomb", 0.25);
				diving = true;
				velocity.x += diveBombBoostX;
				velocity.y = diveBombSetVelY;
				maxVelocity.x *= diveBombMaxVelocityMult;
				maxVelocity.y *= diveBombMaxVelocityMult;
			}
			// Starting a normal jump
			else
			{
				jumped = true;
			}
		}
		
		// Variable Jump Control
		trace('$jumpTimer');
		if ((jumpTimer >= 0) && Input.isPressing(Input.JUMP, controlNumber) && jumped)
		{
			jumpTimer += FlxG.elapsed;
			
			if (isTouching(FlxObject.CEILING))
			{
				jumpTimer += FlxG.elapsed; // double penalty. only half max jump if you hit your head.
				// this was done so you can still recover from a head bonk and push blocks, but your jumping ability is greatly diminished.
			}
			
			if (jumpTimer > .26)
			{
				jumpTimer = -1; // -1 means jump isn't allowed
			}
		}
		else
		{
			jumpTimer = -1;
		}
		
		if (jumpTimer > 0)
		{
			jump();
		}
	}

	public function jump():Void
	{
		// Jump sound
		if (jumpTimer < 0.02)
		{
			landed = false;
			FlxG.sound.play(_jumpStrings[FlxRandom.intRanged(0, _jumpStrings.length-1)]);

			// WALL JUMP KICKBACK
			if (climbing && !isTouching(FlxObject.FLOOR))
			{
				if (facing == FlxObject.LEFT)
					velocity.x = 100;
				else
					velocity.x = -100;
			}
		}
		
		//Jump
		if (jumpTimer < 0.075)
		{
			velocity.y = -jumpStrength * 0.7;
		}
		else if (jumpTimer < 0.15)
		{
			velocity.y = -jumpStrength * 1;
		}
		else if (jumpTimer < 0.24)
		{
			velocity.y = -jumpStrength * 1.1;
		}
		else
		{
			velocity.y = -jumpStrength * 1;
		}
	}

	public function animate():Void
	{
		if (!ridingVehicle)
		{
			if (velocity.y > 0)
			{
				animation.play("fall");
				
			}
			else if (velocity.y < 0)
			{
				animation.play("jump");
			}
			else
			{
				if (velocity.x != 0)
				{
					animation.play("walk");
				}
				else
				{
					animation.play("idle");
				}
			}
		}
		else // riding
		{
			animation.play("idle");
		}
	}

	public function playLandingSound():Void
	{
		FlxG.sound.play("Landing", 0);
	}

	override public function reset(X:Float, Y:Float):Void
	{
		super.reset(X, Y);

		acceleration.y = gravity;
		diving = false;
		drag.x = gravity; // Ground friction
		health = 1;
		jumped = false;
		jumpStrength = 136;
		maxVelocity.x = Reg.RACERSPEED * 2.25;
		maxVelocity.y = 2 * gravity; 
		solid = true;
	}

	public function respawn(X:Float, Y:Float):Void
	{
		reset(X, Y);
		respawnTimer = 2;
		bubble.reset(x - 10, y - 12);
	}

	public function mount(Vehicle:FlxSprite, Aimer:Crosshair):Void
	{
		_crosshair = Aimer;
		_vehicle = Vehicle;
		ridingVehicle = true;
		acceleration.y = 0;
		velocity.x = 0;
		velocity.y = 0;
		facing = FlxObject.LEFT;
		flipX = true;
		solid = false;
	}

	public function dismount():Void
	{
		ridingVehicle = false;
		_vehicle = null;
		_crosshair = null;
		acceleration.y = gravity;
		solid = true;
		x = 0;
		y = 0;
		kill();
	}

	override public function kill():Void
	{
		super.kill();
		deathTimer = 1;
		FlxG.sound.play(_deathStrings[FlxRandom.intRanged(0, _deathStrings.length-1)], 0.25);
		// FlxG.sound.play("Bananabomb");
		// beam.reset(x + width/2, y);
	}

}