package;

import flixel.FlxG;
import flixel.FlxSprite;

class Bomb extends FlxSprite
{

	private var speed:Float = 220;
	private var timer:Float = 0;

	public function new()
	{
		super(0, 0);
		loadGraphic(Reg.BOMB, true, 16, 16);
		width = 12;
		height = 12;
		offset.x = 2;
		offset.y = 2;
		kill();
	}

	override public function update():Void
	{
		angularVelocity = Math.abs(velocity.x) * 3;

		if (!isOnScreen())
			kill();

		super.update();
	}

	public function shoot(P:FlxSprite, Angle:Float):Void
	{
		reset(P.x, P.y + P.height / 2);
		acceleration.y = 200; 
		angularVelocity = -200;
		velocity.x = Math.cos(Angle * Math.PI/180) * speed;
		velocity.y = Math.sin(Angle * Math.PI/180) * speed;
	}

	override public function reset(X:Float, Y:Float):Void
	{
		super.reset(X, Y);
		visible = true;
		solid = true;
	}

	override public function kill():Void
	{
		visible = false;
		solid = false;
		alive = false;
		velocity.x = 0;
		velocity.y = 0;
		acceleration.y = 0;
		super.kill();
	}
}