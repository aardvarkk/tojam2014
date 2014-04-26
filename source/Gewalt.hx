package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.addons.display.FlxExtendedSprite;
import flixel.util.FlxPoint;
import flixel.effects.particles.FlxEmitterExt;
import flixel.effects.particles.FlxParticle;
import flixel.addons.display.FlxExtendedSprite;
import flixel.group.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.XboxButtonID;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;

class Gewalt extends Player
{
	public var weapon:FlxSprite;
	public var explosion:FlxParticle;
	public var daggers:FlxGroup;

	public function new(X:Int, Y:Int)
	{
		super(X, Y);
		gravity = 450;
		moveSpeed = 81;
		maxVelocity.y = 500;
		acceleration.y = gravity;
		jumpStrength = 173;

		loadGraphic(Reg.GEWALT, true, 48, 32);
		width = 13;
		height = 15;
		offset.x = 16;
		offset.y = 16;

		isSelected = false;

		animation.add("idle", [0, 0, 0, 0, 2, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 0, 0], 3, true);
		animation.add("walk", [4, 5, 6], 6, true);	
		animation.add("jump", [8, 9, 10], 12, true);
		animation.add("fall", [8, 9, 10], 12, true);
		animation.add("climb", [12, 13, 14], 8, true);
		animation.add("climbidle", [12, 13, 14], 4, true);
		animation.add("attack1", [16, 17, 18, 19], 18, false);
		animation.add("attack2", [20, 21, 22, 23], 18, false);
		animation.add("attack3", [21, 22, 23], 18, false);
	}

	override public function update():Void
	{
		animate();
		super.update();
	}

	override public function playLandingSound():Void
	{
		FlxG.sound.play("GewaltLand", 0.4);
	}

	override public function controls():Void
	{
		super.controls();
		//attack();
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
}