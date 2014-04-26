package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import flixel.effects.particles.FlxEmitterExt;
import flixel.addons.display.FlxExtendedSprite;
import flixel.group.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.XboxButtonID;
import flixel.input.gamepad.PS4ButtonID;

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

	public var attacking:Bool = false;
	public var attackTimer:Float = -1;
	public var diving:Bool = false;

	public var invulnerable:Bool = false;
	private var invTimer:Float = 0.8;
	private var invDuration:Float = 0.8;

	private var respawnTimer:Float = 0;

	public var bubble:Bubble;

	//#if (!FLX_NO_GAMEPAD && (cpp || neko || js))
	private var gamepad(get, never):FlxGamepad;
	private function get_gamepad():FlxGamepad 
	{
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		if (gamepad == null)
		{
			// Make sure we don't get a crash on neko when no gamepad is active
			gamepad = FlxG.gamepads.getByID(0);
		}
		return gamepad;
	}
	//#end

	public function new(X:Int, Y:Int, Number:Int = 0)
	{
		super(X, Y);

		number = Number;

		if (number == 1)
		{
			loadGraphic(Reg.CORGI2, true, 48, 32);
		}
		else if (number == 2)
		{
			loadGraphic(Reg.CORGI3, true, 48, 32);
		}
		else if (number == 3)
		{
			loadGraphic(Reg.CORGI4, true, 48, 32);
		}
		else
		{
			loadGraphic(Reg.CORGI1, true, 48, 32);
			selected = true;
		}

		if (Reg.UseKeyboard)
		{
			controlSet = number;

			// override if Single controller mode
			if (Reg.SingleControllerMode)
				controlSet = 0;
		}
		// else // for controller inputs

		bubble = new Bubble(X, Y);

		width = 15;
		height = 16;
		offset.x = 16;
		offset.y = 16;

		animation.add("idle", [0, 0, 0, 0, 0, 0, 2, 1, 2, 1, 2, 1], 3, true);
		animation.add("walk", [4, 5, 6, 7], 12, true);	
		animation.add("jump", [5], 8, true);
		animation.add("fall", [6], 8, true);
		animation.add("climb", [8, 9], 8, true);
		animation.add("climbidle", [8], 4, true);
		animation.add("attack", [10], 4, false);

		reset(X, Y);
	}

	override public function update():Void
	{
		// Need to add global pause features later, but skip for now
		if (ridingVehicle)
		{
			x = _vehicle.x + 20;
			y = _vehicle.y + 10;
			ridingControls();
		}
		else
		{
			movingControls();
		}
		animate();

		// Respawn stuff
		if (respawnTimer > 0) // when it was >= 0 there were bugs
		{
			respawnTimer -= FlxG.elapsed;
			velocity.y = 0;
			bubble.x = x - 10;
			bubble.y = y - 12;

			if (isPressing(Reg.JUMP) || respawnTimer <= 0)
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

		if (isPressing(FlxObject.UP) && _vehicle.y >= 40)
		{
			_vehicle.acceleration.y -= runAccel * .5;
		}
		else if (isPressing(FlxObject.DOWN) && _vehicle.y <= FlxG.height - 50)
		{
			_vehicle.acceleration.y += runAccel * .5;
		}

		if (_vehicle.y < 50)
		{
			_vehicle.velocity.y = 0;
			_vehicle.acceleration.y = 0;
			_vehicle.y = 50;
		}
		else if (_vehicle.y > FlxG.height - 40)
		{
			_vehicle.velocity.y = 0;
			_vehicle.acceleration.y = 0;
			_vehicle.y = FlxG.height - 40;
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
		else if (!isTouching(FlxObject.FLOOR))
		{
			landed = false;
		}
		
		// Just hit jump
		// It's either going to trigger a jump or a dive bomb, depending upon whether or not down key is held
		if (FlxG.keys.anyJustPressed([Reg.keyset[controlSet][4]]))
		{
			// if not selected in multi mode exit
			if (Reg.SingleControllerMode == true && selected == false) return;

			// Starting dive bomb
			// If not already diving and BOTH trying to start a jump and holding down, start the divebomb
			// Immediately set vertical velocity
			if (!diving && FlxG.keys.anyPressed([Reg.keyset[controlSet][1]]))
			{
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
		
		if(jumpTimer > 0)
		{
			jump();
		}
	}

	private function isPressing(Direction:Int):Bool
	{
		if (Reg.SingleControllerMode == true && selected == false)
			return false;

		if (Direction == FlxObject.UP)
		{
			if (Reg.UseGamepad)
				return gamepad.dpadUp;
			else
				return (FlxG.keys.anyPressed([Reg.keyset[controlSet][0]]));
		}
		else if (Direction == FlxObject.DOWN)
		{
			if (Reg.UseGamepad)
				return gamepad.dpadDown;
			else
				return (FlxG.keys.anyPressed([Reg.keyset[controlSet][1]]));
		}
		else if (Direction == FlxObject.LEFT)
		{
			if (Reg.UseGamepad)
				return gamepad.dpadLeft;
			else
				return (FlxG.keys.anyPressed([Reg.keyset[controlSet][2]]));
		}
		else if (Direction == FlxObject.RIGHT)
		{
			if (Reg.UseGamepad)
				return gamepad.dpadRight;
			else
				return (FlxG.keys.anyPressed([Reg.keyset[controlSet][3]]));
		}
		else if (Direction == Reg.JUMP)
		{
			if (Reg.UseGamepad)
				return gamepad.justPressed(XboxButtonID.A);
			else
				return (FlxG.keys.anyPressed([Reg.keyset[controlSet][4]]));
		}
		else if (Direction == Reg.KEY1)
		{
			if (Reg.UseGamepad)
				return gamepad.justPressed(XboxButtonID.X);
			else
				return (FlxG.keys.anyPressed([Reg.keyset[controlSet][5]]));
		}
		else if (Direction == Reg.KEY2)
		{
			if (Reg.UseGamepad)
				return gamepad.justPressed(XboxButtonID.Y);
			else
				return (FlxG.keys.anyPressed([Reg.keyset[controlSet][6]]));
		}
		else if (Direction == Reg.KEY3)
		{
			if (Reg.UseGamepad)
				return gamepad.justPressed(XboxButtonID.B);
			else
				return (FlxG.keys.anyPressed([Reg.keyset[controlSet][7]]));
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

	public function playLandingSound():Void
	{
		// Override within the characters themselves
		// FlxG.log.add("playLandingSound()");
		FlxG.sound.play("Landing", 1.0);
	}

	override public function reset(X:Float, Y:Float):Void
	{
		super.reset(X, Y);

		acceleration.y = gravity;
		diving = false;
		drag.x = gravity; // Ground friction
		gravity = 450;
		health = 1;
		jumped = false;
		jumpStrength = 136;
		maxVelocity.x = Reg.RACERSPEED * 1.5;
		maxVelocity.y = 2 * gravity; 
		solid = true;
	}

	public function respawn(X:Float, Y:Float):Void
	{
		reset(X, Y);
		respawnTimer = 2;
		bubble.reset(x - 10, y - 12);
	}

	public function mount(Vehicle:FlxSprite):Void
	{
		_vehicle = Vehicle;
		ridingVehicle = true;
		acceleration.y = 0;
		velocity.x = 0;
		velocity.y = 0;
	}

	public function dismount():Void
	{
		ridingVehicle = false;
		_vehicle = null;
		acceleration.y = gravity;
		x = 0;
		y = 0;
		kill();
	}

}