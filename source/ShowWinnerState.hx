package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxBackdrop;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxSprite;

class ShowWinnerState extends FlxState
{
	private var _backdropsFar:Backdrops;
	private var _backdropsMid:Backdrops;
	private var _backdropsNear:Backdrops;
	private var _weatherEmitter:FlxEmitter;
	private var _waitOver:Bool = false;
	private var _winnerGraphic:FlxSprite;

	override public function create()
	{
		super.create();

		// Set a background color
		FlxG.cameras.bgColor = 0xff4a9294;

		_backdropsFar = new Backdrops(this, Reg.BACKDROPSFAR);
		_backdropsMid = new Backdrops(this, Reg.BACKDROPSMID);

		_weatherEmitter = new FlxEmitter(-240,0,200);
		_weatherEmitter.setSize(720,FlxG.height);
		_weatherEmitter.makeParticles(Reg.PARTICLE,200,0,true,0);
		_weatherEmitter.setXSpeed(-80,-10); // 10-100 looks good - try it in ruins?
		_weatherEmitter.setYSpeed(-150,-50);
		_weatherEmitter.setAlpha(0,1,0,1);
		_weatherEmitter.setRotation(-100,100);
		_weatherEmitter.start(false,10,0.007125);
		add(_weatherEmitter);

		_backdropsNear = new Backdrops(this, Reg.BACKDROPSNEAR);

		var winner = Reg.getWinner();

        var title = new FlxText(0, 80, FlxG.width, 'Player ${winner + 1} Wins!');
        title.size = 40;
        title.color = 0xff111112;
        title.alignment = "center";
        add(title);

        _winnerGraphic = new FlxSprite();
        _winnerGraphic.loadGraphic(Reg.MONKEYS[winner], true, 16, 16);
        _winnerGraphic.x = FlxG.width/2 - _winnerGraphic.width/2;
        _winnerGraphic.y = FlxG.height/2 - _winnerGraphic.height/2 + 30;
   		_winnerGraphic.animation.add("idle", [0, 1, 2, 3], 6, true);
   		_winnerGraphic.scale.set(3, 3);
   		add(_winnerGraphic);

        // var title = new FlxText(0, 80, FlxG.width, "CONCRETE JUNGLE");
        // title.size = 40;
        // title.color = 0xff111112;
        // title.alignment = "center";
        // add(title);
        // title.scrollFactor.x = 0;

        // trace(Reg.scores);
	}

	override public function update()
	{
		super.update();

        _winnerGraphic.animation.play("idle");

		new FlxTimer(2, waitOver);

		if (_waitOver) 
		{
	        var startAgain = new FlxText(0, FlxG.height/2 + 90, FlxG.width, "Press Any Button...");
	        startAgain.alignment = "center";
	        startAgain.color = 0xff111112;
	        add(startAgain);

			if (FlxG.keys.justPressed.ANY || FlxG.gamepads.anyButton()) 
			{
				FlxG.switchState(new MenuState());
			}
		}
	}

	public function waitOver(Timer:FlxTimer)
	{
		_waitOver = true;
	}
}