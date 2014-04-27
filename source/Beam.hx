package;

import flixel.FlxG;
import flixel.FlxSprite;

class Beam extends FlxSprite
{

	private var timer:Float = 0;

	public function new(X:Int, Y:Int)
	{
		super(X, Y);

		loadGraphic(Reg.BEAM, true, 80, 592);
		animation.add("fire", [6,5,4,3,2,1,0,7], 40, false);
		solid = false;
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
		animation.play("fire");
	}

	override public function reset(X:Float, Y:Float):Void
	{
		super.reset(X - width/2, FlxG.height - height);
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