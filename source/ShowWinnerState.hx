package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxTimer;

class ShowWinnerState extends FlxState
{
	public function new()
	{
		super();
	}

	override public function create()
	{
		var winner = Reg.getWinner();

		var text = 'Player ${winner + 1} Wins!\n';
		text += Reg.getScoreString();

		add(new FlxText(0, 0, FlxG.width, text));
	}

	override public function update()
	{
		new FlxTimer(3, waitOver);

		// if (FlxG.keys.justPressed.ANY) 
		// {
		// 	FlxG.switchState(new MenuState());
		// }
	}

	public function waitOver(Timer:FlxTimer)
	{
		FlxG.switchState(new MenuState());
	}
}