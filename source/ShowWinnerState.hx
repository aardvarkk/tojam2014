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
	private var _leafEmitter:LeafEmitter = new LeafEmitter();
	private var _waitOver:Bool = false;
	private var _winnerGraphic:FlxSprite;
  private var _startAgainText:FlxText;

	override public function create()
	{
		super.create();

		// Set a background color
		FlxG.cameras.bgColor = 0xff4a9294;

		_backdropsFar = new Backdrops(this, Reg.BACKDROPSFAR);
		_backdropsMid = new Backdrops(this, Reg.BACKDROPSMID);

		_leafEmitter.init();
		add(_leafEmitter);
		
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

    _startAgainText = new FlxText(0, FlxG.height/2 + 90, FlxG.width, "Press Any Button...");
    _startAgainText.alignment = "center";
    _startAgainText.color = 0xff111112;
    _startAgainText.visible = false;
    add(_startAgainText);

    new FlxTimer(2, waitOver);
	}

	override public function update()
	{
    _winnerGraphic.animation.play("idle");

		if (_waitOver) {
      _startAgainText.visible = true;

			if (FlxG.keys.justPressed.ANY || FlxG.gamepads.anyButton()) {
				FlxG.switchState(new MenuState());
			}
		}

    super.update();
	}

	public function waitOver(Timer:FlxTimer)
	{
    Timer.destroy();
		_waitOver = true;
	}
}