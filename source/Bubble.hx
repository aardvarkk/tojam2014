package;

import flixel.FlxG;
import flixel.FlxSprite;

class Bubble extends FlxSprite
{

	private var timer:Float = 0;

	public function new(X:Int, Y:Int)
	{
		super(X, Y);

		loadGraphic(Reg.BUBBLE, true, 40, 40);
		animation.add("bub", [0,1,2], 12, true);
		animation.add("pop", [3], 6, false);

		kill();
	}

	override public function update():Void
	{
		if (timer > 0)
		{
			timer -= FlxG.elapsed;
			if (timer <= 0)
			{
				kill();
			}
		}

		super.update();
	}

	public function appear():Void
	{
		animation.play("bub");
	}

	public function die():Void
	{
		animation.play("pop");
		timer = 0.25;
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