package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;

import flixel.addons.display.FlxExtendedSprite;

import flixel.util.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;

import flixel.effects.particles.FlxEmitterExt;
import flixel.effects.particles.FlxParticle;

import flixel.addons.display.FlxExtendedSprite;

import flixel.group.FlxTypedGroup;

import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.XboxButtonID;
import flixel.input.gamepad.PS4ButtonID;

class Player1 extends Player
{
	public var weapon:FlxSprite;
	public var tremor:FlxParticle;

	public function new(X:Int, Y:Int)
	{
		super(X, Y);
		gravity = 450;
		moveSpeed = 83;
		maxVelocity.y = 500;
		acceleration.y = gravity;
		jumpStrength = 136;

		loadGraphic(Reg.CORGI1, true, 48, 32);
		width = 12;
		height = 15;
		offset.x = 17;
		offset.y = 16;

		isSelected = true;

		animation.add("idle", [0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2], 3, true);
		animation.add("walk", [3, 4, 5, 3, 6, 7], 10, true);	
		animation.add("jump", [8, 9], 7, true);
		animation.add("fall", [10, 11], 6, true);
		animation.add("climb", [12, 13, 14, 15], 8, true);
		animation.add("climbidle", [12, 16, 18, 17], 4, true);
		animation.add("attack1", [24, 25, 25, 26, 26, 27], 24, false);
		animation.add("attack2", [28, 29, 30, 31, 32], 10, false);
		animation.add("attack3", [38, 39, 40, 41, 34, 35, 36, 37], 30, true);
	}

	override public function update():Void
	{
		animate();
		super.update();
	}

	override public function playLandingSound():Void
	{
		FlxG.sound.play("GrimmerLand", 0.4);
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