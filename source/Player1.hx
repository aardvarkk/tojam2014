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
		maxVelocity.y = 500;
		acceleration.y = gravity;
		jumpStrength = 136;

		loadGraphic(Reg.CORGI1, true, 48, 32);
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
		animate();
		super.update();
	}

	override public function playLandingSound():Void
	{
		super.playLandingSound();
	}

	override public function controls():Void
	{
		super.controls();
		//attack();
	}

	override public function animate():Void
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