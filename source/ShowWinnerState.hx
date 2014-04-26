package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;

class ShowWinnerState extends FlxState
{
	private var _winner:Int;

	public function new(Winner:Int = 1)
	{
		super();
		_winner = Winner;
	}

	override public function create()
	{
		add(new FlxText(0, FlxG.height/2, 100, 'Player $_winner Wins!'));
	}
}