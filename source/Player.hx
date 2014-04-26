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
	public var selected:Bool = false;

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

	public function new(X:Int, Y:Int)
	{
		super(X, Y);

		drag.x = gravity; // Ground friction
		acceleration.y = gravity;

		solid = true;
		diving = false;
		health = 1;
		number = 0; // set for 1p mode for testing by default

		if (number == 2) loadGraphic(Reg.CORGI2, true, 48, 32);
		else if (number == 3) loadGraphic(Reg.CORGI3, true, 48, 32);
		else if (number == 4) loadGraphic(Reg.CORGI4, true, 48, 32);
		else loadGraphic(Reg.CORGI1, true, 48, 32);

		bubble = new Bubble(X, Y);

		width = 15;
		height = 16;
		offset.x = 16;
		offset.y = 16;

		selected = true;

		animation.add("idle", [0, 0, 0, 0, 0, 0, 2, 1, 2, 1, 2, 1], 3, true);
		animation.add("walk", [4, 5, 6, 7], 12, true);	
		animation.add("jump", [5], 8, true);
		animation.add("fall", [6], 8, true);
		animation.add("climb", [8, 9], 8, true);
		animation.add("climbidle", [8], 4, true);
		animation.add("attack", [10], 4, false);
	}

	override public function update():Void
	{
		// Need to add global pause features later, but skip for now
		controls();

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

	public function controls():Void
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
		if (FlxG.keys.anyJustPressed([Reg.keyset[number][4]]))
		{
			// Starting dive bomb
			// If BOTH trying to start a jump and holding down, start the divebomb
			// Immediately set vertical velocity
			if (FlxG.keys.anyPressed([Reg.keyset[number][1]]))
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
		if (number == 0 && selected == false)
			return false;

		if (Direction == FlxObject.UP)
		{
			return (FlxG.keys.anyPressed([Reg.keyset[number][0]]));
		}
		else if (Direction == FlxObject.DOWN)
		{
			return (FlxG.keys.anyPressed([Reg.keyset[number][1]]));
		}
		else if (Direction == FlxObject.LEFT)
		{
			return (FlxG.keys.anyPressed([Reg.keyset[number][2]]));
		}
		else if (Direction == FlxObject.RIGHT)
		{
			return (FlxG.keys.anyPressed([Reg.keyset[number][3]]));
		}
		else if (Direction == Reg.JUMP)
		{
			return (FlxG.keys.anyPressed([Reg.keyset[number][4]]));
		}
		else if (Direction == Reg.KEY1)
		{
			return (FlxG.keys.anyPressed([Reg.keyset[number][5]]));
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

	public function playLandingSound():Void
	{
		// Override within the characters themselves
		FlxG.log.add("playLandingSound()");
		FlxG.sound.play("Landing", 1.0);
	}

	override public function reset(X:Float, Y:Float):Void
	{
		jumped = false;
		super.reset(X, Y);
		diving = false;
		angularVelocity = 0;
		angle = 0;
		maxVelocity.x = Reg.RACERSPEED * 1.5;
		maxVelocity.y = 2 * gravity; 
	}

	public function respawn(X:Float, Y:Float):Void
	{
		reset(X, Y);
		respawnTimer = 2;
		bubble.reset(x - 10, y - 12);
	}

}