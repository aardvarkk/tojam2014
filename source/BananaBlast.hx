package;

import flixel.FlxG;
import flixel.FlxSprite;

class BananaBlast extends FlxSprite
{

	public function new()
	{
		super(0, 0);
		loadGraphic(Reg.BANANA_BLAST, true, 47, 47);

		animation.add("boom",[0,1,2,3,4,5,6,7],24, false);

		kill();
	}

	override public function update():Void
	{

		if (!isOnScreen())
			kill();

		super.update();
	}

	public function boom(P:FlxSprite, ?Vx:Float = 0, ?Vy:Float = 0):Void
	{
		reset(P.x + P.width / 2 - (width / 2), P.y + P.height / 2 - (width / 2));
		velocity.x = Vx;
		velocity.y = Vy;
		animation.play("boom");
		FlxG.sound.play("BombBlast", 0.3);
	}

	override public function reset(X:Float, Y:Float):Void
	{
		super.reset(X, Y);
		visible = true;
	}

	override public function kill():Void
	{
		visible = false;
		alive = false;
		velocity.x = 0;
		velocity.y = 0;
		super.kill();
	}
}