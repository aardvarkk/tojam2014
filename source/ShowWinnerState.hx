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
	private var _cloudsFar:FlxBackdrop;
	private var _cloudsMid:FlxBackdrop;
	private var _cloudsNear:FlxBackdrop;
	private var _mountainsFar:FlxBackdrop;
	private var _buildingsMid:FlxBackdrop;
	private var _buildingsNear:FlxBackdrop;
	private var _foreground:FlxBackdrop;
	private var _foreground2:FlxBackdrop;
	private var _mist:FlxBackdrop;
	private var _mist2:FlxBackdrop;
	private var _weatherEmitter:FlxEmitter;
	private var _waitOver:Bool = false;
	private var _winnerGraphic:FlxSprite;

	override public function create()
	{
		super.create();

		// Set a background color
		FlxG.cameras.bgColor = 0xff4a9294;

		_cloudsFar = new FlxBackdrop(Reg.CLOUDSFAR,0.125,0,true,false);
		_cloudsMid = new FlxBackdrop(Reg.CLOUDSMID,0.25,0,true,false);
		_cloudsNear = new FlxBackdrop(Reg.CLOUDSNEAR,0.5,0,true,false);
		_mountainsFar = new FlxBackdrop(Reg.MOUNTAINSFAR,0.1,0,true,false);
		_buildingsMid = new FlxBackdrop(Reg.BUILDINGSMID,0.2,0,true,false);
		_mist = new FlxBackdrop(Reg.MIST,0.45,0,true,false);
		_buildingsNear = new FlxBackdrop(Reg.BUILDINGSNEAR,0.4,0,true,false); 
		_mist2 = new FlxBackdrop(Reg.MIST2,1.15,0,true,false);
		_foreground = new FlxBackdrop(Reg.JUNGLEFOLIAGE,1.3,0,true,false);
		
		_mountainsFar.y = FlxG.height - 180;
		_buildingsMid.y = FlxG.height - 128;
		_buildingsNear.y = FlxG.height - 80;
		_mist.y = FlxG.height - 138; // actually 128 though
		_mist2.y = FlxG.height - 98; // actually 128 though
		_foreground2.y = FlxG.height - 48;

		_weatherEmitter = new FlxEmitter(-240,0,200);
		_weatherEmitter.setSize(720,FlxG.height);
		_weatherEmitter.makeParticles(Reg.PARTICLE,200,0,true,0);
		_weatherEmitter.setXSpeed(-80,-10); // 10-100 looks good - try it in ruins?
		_weatherEmitter.setYSpeed(-150,-50);
		_weatherEmitter.setAlpha(0,1,0,1);
		_weatherEmitter.setRotation(-100,100);
		_weatherEmitter.start(false,10,0.007125);

		add(_cloudsFar);
		add(_mountainsFar);
		add(_cloudsMid);
		add(_buildingsMid);
		add(_mist);
		add(_cloudsNear);
		add(_buildingsNear);
		add(_mist2);
		add(_weatherEmitter);
		add(_foreground);
		add(_foreground2);

		var winner = Reg.getWinner();

        var title = new FlxText(0, 80, FlxG.width, 'Player ${winner + 1} Wins!');
        title.size = 40;
        title.color = 0xff111112;
        title.alignment = "center";
        add(title);

        _winnerGraphic = new FlxSprite();
        if (winner == 0)
        {
        	_winnerGraphic.loadGraphic(Reg.MONKEY1, true, 16, 16);
        }
        else if (winner == 1)
        {
        	_winnerGraphic.loadGraphic(Reg.MONKEY2, true, 16, 16);
        }
        else if (winner == 2)
        {
        	_winnerGraphic.loadGraphic(Reg.MONKEY3, true, 16, 16);
        }
        else
        {
        	_winnerGraphic.loadGraphic(Reg.MONKEY4, true, 16, 16);
        }

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