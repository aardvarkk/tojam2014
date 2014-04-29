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
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.XboxButtonID;
import flixel.input.gamepad.PS4ButtonID;
import flixel.util.FlxRandom;

class Player extends FlxExtendedSprite
{
	public var number:Int;
	public var controlSet:Int = 0;
	public var selected:Bool = false;

	public var ridingVehicle:Bool = false;
	private var _vehicle:FlxSprite;

	public var gravity:Float = 450;
	private var jumpTimer:Float;
	private var jumpStrength:Float = 100;
	private var runAccel = 900;
	private var diveBombMaxVelocityMult = 3; // Multiplier to max velocity
	private var diveBombBoostX = 300; // Instant boost to velocity in X
	private var diveBombSetVelY = 100; // Instant set to velocity in Y
	private var jumped:Bool = false;
	private var landed:Bool = false;
	public var climbing:Bool = false;
	private var _bombs:FlxTypedGroup<Bomb>;
	private var _boomerangs:FlxTypedGroup<Boomerang>;
	private var _missiles:FlxTypedGroup<Missile>;

	public var attacking:Bool = false;
	public var attackTimer:Float = 0;
	public var ATTACKDELAY:Float = 0.5;
	public var diving:Bool = false;

	public var invulnerable:Bool = false;
	private var invTimer:Float = 0.8;
	private var invDuration:Float = 0.8;

	public var deathTimer:Float = 0;

	private var respawnTimer:Float = 0;

	public var bubble:Bubble;
	public var beam:Beam;

	private var _aim:Float = 180;
	private var _crosshair:Crosshair;

	private var _jumpStrings = ["LightOoh", "TinyOoh1", "TinyOoh2", "TinyOoh3", "TinyOoh4", "TinyOoh5", "TinyOoh6", "TinyOoh7", "TinyOoh8", "TinyOoh9"];
	private var _deathStrings = ["Megascreech1", "Megascreech2", "Megascreech3", "Squak"];
	private var _gamepad:FlxGamepad;
	public var autoscrollMonkey:Bool = false;
	private var autoJumpTimer:Float = 0;
	private var autoJumpDelay:Float = 0.1;

	public function new(X:Int, Y:Int, Number:Int, Bombs:FlxTypedGroup<Bomb>, Boomerangs:FlxTypedGroup<Boomerang>, Missiles:FlxTypedGroup<Missile>)
	{
		super(X, Y);

		number = Number;
		_bombs = Bombs; // ref to the bomb group
		_boomerangs = Boomerangs;
		_missiles = Missiles;

		if (number == 0)
		{
			loadGraphic(Reg.MONKEY1, true, 16, 16);
			selected = true;
		}
		else if (number == 1)
		{
			loadGraphic(Reg.MONKEY2, true, 16, 16);
		}
		else if (number == 2)
		{
			loadGraphic(Reg.MONKEY3, true, 16, 16);
		}
		else
		{
			loadGraphic(Reg.MONKEY4, true, 16, 16);
		}

		if (Reg.KeyboardControlSet[number] != null)
		{
			controlSet = Reg.KeyboardControlSet[number];
			FlxG.log.add('Player $number using keyboard control set $controlSet');
		}
		else
		{
			if (!Reg.SinglePlayerDebug)
				_gamepad = FlxG.gamepads.getByID(Number); // grab our gamepad
			else
				_gamepad = FlxG.gamepads.getByID(0); // grab the 1st gamepad
			FlxG.log.add('Player $number using gamepad ${_gamepad.id}');
			// For the sufami controllers, ABXY is the same as PS4 placement
			// but the dpad is AxisX(0) for left (-1) and right (1)
			// and AxisX(1) for up (-1) and down (1) where 0 is no input
			// Forgot to commit two things separately so added this so I could make a new commit
			// Added support for the USB controllers I have
			// which use AxisX(0) for dpad X
			// and AxisX(1) for dpad Y
		}

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

			if (PlayState.currentlySelectedPlayer == number)
				ridingControls();
		}
		else
		{
			if (PlayState.currentlySelectedPlayer == number)
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
		}

		animate();

		// Respawn stuff
		if (respawnTimer > 0) // when it was >= 0 there were bugs
		{
			respawnTimer -= FlxG.elapsed;
			velocity.y = 0;
			bubble.x = x - 10;
			bubble.y = y - 12;

			if (isPressing(Reg.JUMP) || x > FlxG.camera.scroll.x + 100 || respawnTimer <= 0)
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

	public function ridingControls():Void
	{
		_vehicle.acceleration.y = 0;

		if (isPressing(FlxObject.UP) && (_vehicle.y + _vehicle.height/2 > FlxG.height/2))
		{
			_vehicle.acceleration.y -= runAccel * .25;
		}
		else if (isPressing(FlxObject.DOWN) && (_vehicle.y + _vehicle.height < FlxG.height))
		{
			_vehicle.acceleration.y += runAccel * .25;
		}

		if (isPressing(FlxObject.LEFT))
		{
			_aim -= 4;
		}
		else if (isPressing(FlxObject.RIGHT))
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
			if (isPressing(Reg.KEY1))
			{
				FlxG.log.add("Shot a bomb!");
				_bombs.recycle(Bomb,[],true,false).shoot(this, _aim);
				attackTimer = ATTACKDELAY;
			}
			else if (isPressing(Reg.KEY2))
			{
				FlxG.log.add("Shot a boomerang!");
				_boomerangs.recycle(Boomerang,[],true,false).shoot(this, _aim);
				attackTimer = ATTACKDELAY;
			}
			else if (isPressing(Reg.KEY3))
			{
				FlxG.log.add("Shot a missile!");
				_missiles.recycle(Missile,[],true,false).shoot(this, _aim);
				attackTimer = ATTACKDELAY;
			}
		}
	}

	public function movingControls():Void
	{
		acceleration.x = 0;

		// Move Left
		if (isPressing(FlxObject.LEFT))
		{
			flipX = true;
			facing = FlxObject.LEFT;
			acceleration.x -= runAccel;
		}
		
		// Move Right
		if (isPressing(FlxObject.RIGHT))
		{
			flipX = false;
			facing = FlxObject.RIGHT;
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
		if (isJustPressing(Reg.JUMP))
		{
			// Starting dive bomb
			// If not already diving and BOTH trying to start a jump and holding down, start the divebomb
			// Immediately set vertical velocity
			if (!diving && isPressing(FlxObject.DOWN))
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
		if ((jumpTimer >= 0) && isPressing(Reg.JUMP) && jumped)
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

	private function isPressing(Direction:Int):Bool
	{
		if (Direction == FlxObject.UP)
		{
			if (Reg.KeyboardControlSet[number] == null)
			{
				if (_gamepad.getXAxis(1) == -1)
					return true;
				else
					return _gamepad.dpadUp;
			}
			else
				return (FlxG.keys.anyPressed([Reg.keyset[controlSet][0]]));
		}
		else if (Direction == FlxObject.DOWN)
		{
			if (Reg.KeyboardControlSet[number] == null)
			{
				if (_gamepad.getXAxis(1) == 1)
					return true;
				else
					return _gamepad.dpadDown;
			}
			else
				return (FlxG.keys.anyPressed([Reg.keyset[controlSet][1]]));
		}
		else if (Direction == FlxObject.LEFT)
		{
			if (Reg.KeyboardControlSet[number] == null)
			{
				if (_gamepad.getXAxis(0) == -1)
					return true;
				else
					return _gamepad.dpadLeft;
			}
			else
				return (FlxG.keys.anyPressed([Reg.keyset[controlSet][2]]));
		}
		else if (Direction == FlxObject.RIGHT)
		{
			if (Reg.KeyboardControlSet[number] == null)
			{
				if (_gamepad.getXAxis(0) == 1)
					return true;
				else
					return _gamepad.dpadRight;
			}
			else
				return (FlxG.keys.anyPressed([Reg.keyset[controlSet][3]]));
		}
		else if (Direction == Reg.JUMP)
		{
			if (Reg.KeyboardControlSet[number] == null)
				return _gamepad.pressed(PS4ButtonID.X_BUTTON);
			else
				return (FlxG.keys.anyPressed([Reg.keyset[controlSet][4]]));
		}
		else if (Direction == Reg.KEY1)
		{
			if (Reg.KeyboardControlSet[number] == null)
				return _gamepad.pressed(PS4ButtonID.SQUARE_BUTTON);
			else
				return (FlxG.keys.anyPressed([Reg.keyset[controlSet][5]]));
		}
		else if (Direction == Reg.KEY2)
		{
			if (Reg.KeyboardControlSet[number] == null)
				return _gamepad.pressed(PS4ButtonID.TRIANGLE_BUTTON);
			else
				return (FlxG.keys.anyPressed([Reg.keyset[controlSet][6]]));
		}
		else if (Direction == Reg.KEY3)
		{
			if (Reg.KeyboardControlSet[number] == null)
				return _gamepad.pressed(PS4ButtonID.CIRCLE_BUTTON);
			else
				return (FlxG.keys.anyPressed([Reg.keyset[controlSet][7]]));
		}
		else
		{
			return false;
		}
	}

	private function isJustPressing(Direction:Int):Bool
	{
		if (Direction == FlxObject.UP)
		{
			if (Reg.KeyboardControlSet[number] == null)
				return _gamepad.dpadUp;
			else
				return (FlxG.keys.anyJustPressed([Reg.keyset[controlSet][0]]));
		}
		else if (Direction == FlxObject.DOWN)
		{
			if (Reg.KeyboardControlSet[number] == null)
				return _gamepad.dpadDown;
			else
				return (FlxG.keys.anyJustPressed([Reg.keyset[controlSet][1]]));
		}
		else if (Direction == FlxObject.LEFT)
		{
			if (Reg.KeyboardControlSet[number] == null)
				return _gamepad.dpadLeft;
			else
				return (FlxG.keys.anyJustPressed([Reg.keyset[controlSet][2]]));
		}
		else if (Direction == FlxObject.RIGHT)
		{
			if (Reg.KeyboardControlSet[number] == null)
				return _gamepad.dpadRight;
			else
				return (FlxG.keys.anyJustPressed([Reg.keyset[controlSet][3]]));
		}
		else if (Direction == Reg.JUMP)
		{
			if (Reg.KeyboardControlSet[number] == null)
				return _gamepad.justPressed(PS4ButtonID.X_BUTTON);
			else
				return (FlxG.keys.anyJustPressed([Reg.keyset[controlSet][4]]));
		}
		else if (Direction == Reg.KEY1)
		{
			if (Reg.KeyboardControlSet[number] == null)
				return _gamepad.justPressed(PS4ButtonID.SQUARE_BUTTON);
			else
				return (FlxG.keys.anyJustPressed([Reg.keyset[controlSet][5]]));
		}
		else if (Direction == Reg.KEY2)
		{
			if (Reg.KeyboardControlSet[number] == null)
				return _gamepad.justPressed(PS4ButtonID.TRIANGLE_BUTTON);
			else
				return (FlxG.keys.anyJustPressed([Reg.keyset[controlSet][6]]));
		}
		else if (Direction == Reg.KEY3)
		{
			if (Reg.KeyboardControlSet[number] == null)
				return _gamepad.justPressed(PS4ButtonID.CIRCLE_BUTTON);
			else
				return (FlxG.keys.anyJustPressed([Reg.keyset[controlSet][7]]));
		}
		else
		{
			return false;
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