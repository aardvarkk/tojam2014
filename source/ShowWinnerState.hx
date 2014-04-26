package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;

class ShowWinnerState extends FlxState
{
	private var _winner:Int;

	public function new(Winner:Int = 0)
	{
		super();
		_winner = Winner;
	}

	override public function create()
	{
		var winningPlayerNumber = _winner + 1;
		add(new FlxText(0, FlxG.height/2, 100, 'Player $winningPlayerNumber Wins!'));
	}
}