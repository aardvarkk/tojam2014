package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxPoint;
import flixel.effects.particles.FlxEmitterExt;
import flixel.addons.display.FlxExtendedSprite;
import flixel.group.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.XboxButtonID;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;

class Player extends FlxExtendedSprite
{
	public var number:Int;
	public var isSelected:Bool = false;

	public var jumpTimer:Float;
	public var jumpStrength:Float = 100;
	public var jumped:Bool = false;

	public var forceWalk:Bool = false;
	public var forceFacing:UInt = 0;
	public var forceUpdateMovement:Bool = false;
	public var baseSprite:FlxSprite;

	public var forceIdle:Bool = false;

	public var canClimb:Bool = false;
	public var onLadder:Bool = false;
	public var isClimbing:Bool = false;

	public var JUMP:Int = 10;
	public var ATTACK:Int = 20;

	public var attacking:Bool = false;
	public var attackTimer:Float = -1;
	public var comboNumber:Int = 0;
	public var comboWindow:Float = 0.5;

	public var invulnerable:Bool = false;
	public var invTimer:Float = 0.8;
	public var INV_DURATION:Float = 0.8;

	public var respawning:Bool = false;
	public var respawnTimer:Float = 0;
	public var justDied:Bool = false;

	public var moveSpeed:Float = 0;

	public var inWater:Bool = false;
	public var wasInWater:Bool = false;

	public var mute:Bool = false;
	public var muteTimer:Float = 0;

	public static var keys:Array<Dynamic> =
	[
		["UP", "DOWN", "LEFT", "RIGHT", "Z", "X", "A", "S"],
		["UP", "DOWN", "LEFT", "RIGHT", "PERIOD", "SLASH"],
		["T", "G", "F", "H", "Z", "X"]
	];

	public var cpLadder:Bool = false;

	// some stuff that was in TGSprite - not sure if I want to bring that over
	// might be easier to just reset the whole room, you know?

	public var resetPoint:FlxPoint;

	public var gravity:Float = 400;

	public var cutscene:Bool = false;

	public var landed:Bool = false;

	public var normalMaxVelocity:FlxPoint;

	public function new(X:Int, Y:Int)
	{
		super(X, Y);
		resetPoint = new FlxPoint(x, y);
		normalMaxVelocity = new FlxPoint(80, gravity * 2);
		maxVelocity.x = 400;
		normalMaxVelocity.x = 80;
		maxVelocity.y = 500;
		acceleration.y = gravity;
		drag.x = normalMaxVelocity.x * 10;

		solid = true;
		health = 1;
		number = 0;
	}

	override public function update():Void
	{
		// Need to add global pause features later, but skip for now
		controls();

		super.update();

		trace("landed: " + landed);
		trace("jumped: " + jumped);
		trace("timer: " + jumpTimer);
	}

	public function controls():Void
	{
		acceleration.x = 0;

		// Move Left
		if (isPressing(FlxObject.LEFT))
		{
			if (!onLadder && !forceWalk) // can't adjust when on ladder or forced to walk ie boulder riding
			{
				flipX = true;
				facing = FlxObject.LEFT;
				//acceleration.x = -maxVelocity.x * 20; //velocity.x = -maxVelocity.x;
				if (velocity.x > -normalMaxVelocity.x)
					velocity.x -= normalMaxVelocity.x * .5;
			}
				
		}
		
		// Move Right
		if (isPressing(FlxObject.RIGHT))
		{
			flipX = false;
			if (!onLadder && !forceWalk) // can't adjust when on ladder or forced to walk ie boulder riding
			{
				facing = FlxObject.RIGHT;
				//acceleration.x = maxVelocity.x * 20; //velocity.x = maxVelocity.x;
				if (velocity.x < normalMaxVelocity.x)
					velocity.x += normalMaxVelocity.x * .5; // 20%
			}
		}
		
		// Jump Reset
		if (isTouching(FlxObject.FLOOR))
		{
			trace("touching floor");
			if (landed == false)
			{
				if (muteTimer < 0 && !onLadder)
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
		if (isPressing(JUMP) == true)
		{
			jumped = true;
		}
		
		// Variable Jump Control
		if ((jumpTimer >= 0) && isPressing(JUMP) && jumped)
		{
			jumpTimer += FlxG.elapsed;
			
			if (isTouching(FlxObject.CEILING))
			{
				jumpTimer += FlxG.elapsed; // double penalty. only half max jump if you hit your head.
				// this was done so you can still recover from a head bonk and push blocks, but your jumping ability is greatly diminished.
			}
			
			if ((!inWater && jumpTimer > .26) || (inWater && jumpTimer > 1.5))
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
		
		//Drop from ladder
		if (onLadder && isPressing(JUMP))
		{
			offLadder(); //jumping kicks you off any ladder you might be on.
		}
	}

	private function isPressing(Direction:Int):Bool
	{
		if (Direction == FlxObject.UP)
		{
			if (number == 0 && isSelected)
				return (FlxG.keys.anyPressed([keys[0][0]]));
			else if (number > 0)
				return (FlxG.keys.anyPressed([keys[number][0]]));
			else
				return false;
		}
		else if (Direction == FlxObject.DOWN)
		{
			if (number == 0 && isSelected)
				return (FlxG.keys.anyPressed([keys[0][1]]));
			else if (number > 0)
				return (FlxG.keys.anyPressed([keys[number][1]]));
			else
				return false;
		}
		else if (Direction == FlxObject.LEFT)
		{
			if (number == 0 && isSelected)
				return (FlxG.keys.anyPressed([keys[0][2]]));
			else if (number > 0)
				return (FlxG.keys.anyPressed([keys[number][2]]));
			else
				return false;
		}
		else if (Direction == FlxObject.RIGHT)
		{
			if (number == 0 && isSelected)
				return (FlxG.keys.anyPressed([keys[0][3]]));
			else if (number > 0)
				return (FlxG.keys.anyPressed([keys[number][3]]));
			else
				return false;
		}
		else if (Direction == JUMP)
		{
			if (number == 0 && isSelected)
			{
				return (FlxG.keys.anyPressed([keys[0][4]]));
				trace("pressed the jump key");
			}
			else if (number > 0)
				return (FlxG.keys.anyPressed([keys[number][4]]));
			else
				return false;
		}
		else if (Direction == ATTACK)
		{
			if (number == 0 && isSelected)
				return (FlxG.keys.anyPressed([keys[0][5]]));
			else if (number > 0)
				return (FlxG.keys.anyPressed([keys[number][5]]));
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
		if (!inWater)
		{
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
		else
		{
			if (jumpTimer < 0.5)
			{
				velocity.y = -jumpStrength * 1;//-.22;//-.3;
			}
			else if (jumpTimer < 0.1)
			{
				velocity.y = -jumpStrength * 1.5;//26;//-.35;
			}
			else if (jumpTimer < 0.5)
			{
				velocity.y = -jumpStrength * 2;//-.3;//-.4;
			}
			else if (jumpTimer < 2)
			{
				velocity.y = -jumpStrength * 1;
			}
			else
			{
				velocity.y = -jumpStrength * 1;//-.5;
			}
		}
	}

	public function playLandingSound():Void
	{
		// Override within the characters themselves
	}

	public function offLadder():Void
	{
		isClimbing = false;
		onLadder = false;
		acceleration.y = gravity;
	}
}