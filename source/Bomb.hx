package;

import flixel.FlxG;
import flixel.FlxSprite;

class Bubble extends FlxSprite
{

	private var timer:Float = 0;

	public function new(X:Int, Y:Int)
	{
		super(X, Y);
		loadGraphic(Reg.BOMB, true, 16, 16);
		kill();
	}

	override public function update():Void
	{
		super.update();
	}

	public function throw(Angle:Float):Void
	{
		animation.play("bub");
	}

	override public function reset(X:Float, Y:Float):Void
	{
		super.reset(X, Y);
		visible = true;
		solid = false;
		appear();
	}

	override public function kill():Void
	{
		visible = false;
		super.kill();
	}
}