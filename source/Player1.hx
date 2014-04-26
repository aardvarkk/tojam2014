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
		width = 16;
		height = 15;
		offset.x = 15;
		offset.y = 16;

		selected = true;
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