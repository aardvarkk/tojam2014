package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();

		FlxG.sound.playMusic("music", 0.3, true);

		// Set a background color
        FlxG.cameras.bgColor = 0xff111112;

        var title = new FlxText(0, FlxG.height/2, FlxG.width, "Our Game Title");
        title.alignment = "center";
        add(title);

        var choosePlayers = new FlxText(0, FlxG.height/2 + 50, FlxG.width, "Choose Number of Players (2-4)");
        choosePlayers.alignment = "center";
        add(choosePlayers);
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();

		if (FlxG.keys.anyJustPressed(["TWO", "THREE", "FOUR"]))
		{
			if (FlxG.keys.anyJustPressed(["TWO"])) {
				FlxG.switchState(new PlayState(2));	
			}
			else if (FlxG.keys.anyJustPressed(["THREE"])) {
				FlxG.switchState(new PlayState(3));	
			}
			else if (FlxG.keys.anyJustPressed(["FOUR"])) {
				FlxG.switchState(new PlayState(4));	
			}			
		}
	}	
}