package;

import flixel.FlxG;
import flixel.effects.particles.FlxEmitter;

class LeafEmitter extends FlxEmitter
{
	public function new()
	{
		super(-240,0,200);
	}

	public function init()
	{
		setSize(720, FlxG.height);
		makeParticles(Reg.LEAVES, 200, 0, true, 0);
		setXSpeed(-80, -10); // 10-100 looks good - try it in ruins?
		setYSpeed(-150, -50);
		setAlpha(0, 1, 0, 1);
		setRotation(-100, 100);
		start(false, 10, 0.007125);
	}

	override public function update()
	{
		super.update();

		// Keep on screen
		x = FlxG.camera.scroll.x;
	}
}