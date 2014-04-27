package;

import flixel.FlxG;
import flixel.FlxSprite;

class Bomb extends FlxSprite
{

	private var speed:Float = 200;
	private var timer:Float = 0;

	public function new()
	{
		super(0, 0);
		loadGraphic(Reg.BOMB, true, 16, 16);
		kill();
	}

	override public function update():Void
	{
		super.update();
	}

	public function shoot(P:FlxSprite, Angle:Float):Void
	{
		reset(P.x, P.y + P.height / 2);
		acceleration.y = 300; // gravity
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