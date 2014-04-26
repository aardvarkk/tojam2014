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

	private var jumpTimer:Float;
	private var jumpStrength:Float = 100;
	private var jumped:Bool = false;
	private var landed:Bool = false;

	public var attacking:Bool = false;
	public var attackTimer:Float = -1;

	public var invulnerable:Bool = false;
	private var invTimer:Float = 0.8;
	private var invDuration:Float = 0.8;

	private var respawning:Bool = false;
	private var respawnTimer:Float = 0;
	private var justDied:Bool = false;

	private var moveSpeed:Float = 0;
	public var gravity:Float = 400;
	private var normalMaxVelocity:FlxPoint;

	public function new(X:Int, Y:Int)
	{
		super(X, Y);

		normalMaxVelocity = new FlxPoint(80, gravity * 2);
		maxVelocity.x = 400;
		normalMaxVelocity.x = 80;
		maxVelocity.y = 500;
		acceleration.y = gravity;
		drag.x = normalMaxVelocity.x * 10;

		solid = true;
		health = 1;
		number = 0; // set for 1p mode for testing by default

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
			//acceleration.x = -maxVelocity.x * 20; //velocity.x = -maxVelocity.x;
			if (velocity.x > -normalMaxVelocity.x)
				velocity.x -= normalMaxVelocity.x * .5;
		}
		
		// Move Right
		if (isPressing(FlxObject.RIGHT))
		{
			flipX = false;
			facing = FlxObject.RIGHT;
			//acceleration.x = maxVelocity.x * 20; //velocity.x = maxVelocity.x;
			if (velocity.x < normalMaxVelocity.x)
				velocity.x += normalMaxVelocity.x * .5; // 20%
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
		
		//prevent bouncy mode
		if (isPressing(Reg.JUMP) == true)
		{
			jumped = true;
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
		if (Direction == FlxObject.UP)
		{
			if (number == 0 && selected)
				return (FlxG.keys.anyPressed([Reg.keyset[0][0]]));
			else if (number > 0)
				return (FlxG.keys.anyPressed([Reg.keyset[number][0]]));
			else
				return false;
		}
		else if (Direction == FlxObject.DOWN)
		{
			if (number == 0 && selected)
				return (FlxG.keys.anyPressed([Reg.keyset[0][1]]));
			else if (number > 0)
				return (FlxG.keys.anyPressed([Reg.keyset[number][1]]));
			else
				return false;
		}
		else if (Direction == FlxObject.LEFT)
		{
			if (number == 0 && selected)
				return (FlxG.keys.anyPressed([Reg.keyset[0][2]]));
			else if (number > 0)
				return (FlxG.keys.anyPressed([Reg.keyset[number][2]]));
			else
				return false;
		}
		else if (Direction == FlxObject.RIGHT)
		{
			if (number == 0 && selected)
				return (FlxG.keys.anyPressed([Reg.keyset[0][3]]));
			else if (number > 0)
				return (FlxG.keys.anyPressed([Reg.keyset[number][3]]));
			else
				return false;
		}
		else if (Direction == Reg.JUMP)
		{
			if (number == 0 && selected)
			{
				return (FlxG.keys.anyPressed([Reg.keyset[0][4]]));
			}
			else if (number > 0)
				return (FlxG.keys.anyPressed([Reg.keyset[number][4]]));
			else
				return false;
		}
		else if (Direction == Reg.KEY1)
		{
			if (number == 0 && selected)
				return (FlxG.keys.anyPressed([Reg.keyset[0][5]]));
			else if (number > 0)
				return (FlxG.keys.anyPressed([Reg.keyset[number][5]]));
			else
				return false;
		}
		else
		{
			// you're out of control in the most literal sense
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
			velocity.y = -jumpStrength * 0.7;//-.22;//-.3;
		}
		else if (jumpTimer < 0.15)
		{
			velocity.y = -jumpStrength * 1;//26;//-.35;
		}
		else if (jumpTimer < 0.24)
		{
			velocity.y = -jumpStrength * 1.1;//-.3;//-.4;
		}
		else
		{
			velocity.y = -jumpStrength * 1;//-.5;
		}
	}

	public function playLandingSound():Void
	{
		// Override within the characters themselves
		FlxG.sound.play("GrimmerLand", 0.4);
	}

}