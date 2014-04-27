package;

import flixel.FlxG;
import flixel.FlxState;
import openfl.Assets;

/**
* Title screen FlxState
*/
class TitleState extends FlxState
{

	override public function create():Void
	{
		super.create();

		//FlxG.vcr.loadReplay(Assets.getText("data/demo1.txt"), new MenuState(), ["ANY"], 45, MenuState.pressedStart);
	}

}