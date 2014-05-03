package;

import flixel.FlxG;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.PS4ButtonID;

class Input
{
	// USB Super Famicom controller note
	// face button ID for ABXY correspond to PS4 OXSqTr (0123)
	// dpad L and R are on AxisX(0) (-1 and 1 respectively; 0 is no input)
	// dpad U and D are on AxisX(1) (-1 and 1 respectively; 0 is no input)

	public static inline var UP      = 0;
	public static inline var DOWN    = 1;
	public static inline var LEFT    = 2;
	public static inline var RIGHT   = 3;
	public static inline var JUMP    = 4;
	public static inline var ACTION1 = 5;
	public static inline var ACTION2 = 6;
	public static inline var ACTION3 = 7;
	public static inline var START   = 8;

	public static function isPressing(Action:Int, Number:Int):Bool
	{
		var gamepad = null;
		var style = Reg.SINGLE_PLAYER_MODE ? Reg.SINGLE_PLAYER_CONTROLSTYLE : Reg.ControlStyles[Number];
		
		// If the settings are set to gamepad but there is no gamepad, fall back to keyboard.
		// If you don't do this, someone who has no gamepad to plug in can't even change the settings.
		if (FlxG.gamepads.numActiveGamepads < Number + 1)
		{
			style = ControlStyle.Keyboard;
		}
		else
		{
			// getByID always returns a gamepad
			// If nothing is plugged in, the gamepad that's returned just has nothing pressed
			// But returning a gamepad value when there is no gamepad doesn't seem to be a wise practice, since it blinds the game as to what's actually plugged in
			gamepad = FlxG.gamepads.getByID(Number);
		}
		
		switch (style) {
			case Keyboard:
				return FlxG.keys.anyPressed([Reg.KeyboardControls[Number][Action]]);
			case Gamepad:
				switch (Action) {
					case UP      : return gamepad.getXAxis(1) == -1 || gamepad.dpadUp;
					case DOWN    : return gamepad.getXAxis(1) ==  1 || gamepad.dpadDown;
					case LEFT    : return gamepad.getXAxis(0) == -1 || gamepad.dpadLeft;
					case RIGHT   : return gamepad.getXAxis(0) ==  1 || gamepad.dpadRight;
					case JUMP    : return gamepad.pressed(PS4ButtonID.X_BUTTON);
					case ACTION1 : return gamepad.pressed(PS4ButtonID.SQUARE_BUTTON);
					case ACTION2 : return gamepad.pressed(PS4ButtonID.TRIANGLE_BUTTON);
					case ACTION3 : return gamepad.pressed(PS4ButtonID.CIRCLE_BUTTON);
					case START   : return gamepad.pressed(7) || gamepad.pressed(PS4ButtonID.START_BUTTON);
				}
		}
		return false;
	}

	public static function isJustPressing(Action:Int, Number:Int):Bool
	{
		var gamepad = null;
		var style = Reg.SINGLE_PLAYER_MODE ? Reg.SINGLE_PLAYER_CONTROLSTYLE : Reg.ControlStyles[Number];
		
		// If the settings are set to gamepad but there is no gamepad, fall back to keyboard.
		// If you don't do this, someone who has no gamepad to plug in can't even change the settings.
		if (FlxG.gamepads.numActiveGamepads < Number + 1)
		{
			style = ControlStyle.Keyboard;
		}
		else
		{
			// getByID always returns a gamepad
			// If nothing is plugged in, the gamepad that's returned just has nothing pressed
			// But returning a gamepad value when there is no gamepad doesn't seem to be a wise practice, since it blinds the game as to what's actually plugged in
			gamepad = FlxG.gamepads.getByID(Number);
		}

		switch (style) {
			case Keyboard:
				return FlxG.keys.anyJustPressed([Reg.KeyboardControls[Number][Action]]);
			case Gamepad:
				switch (Action) {
					case UP      : return gamepad.getXAxis(1) == -1 || gamepad.dpadUp;
					case DOWN    : return gamepad.getXAxis(1) ==  1 || gamepad.dpadDown;
					case LEFT    : return gamepad.getXAxis(0) == -1 || gamepad.dpadLeft;
					case RIGHT   : return gamepad.getXAxis(0) ==  1 || gamepad.dpadRight;
					case JUMP    : return gamepad.justPressed(PS4ButtonID.X_BUTTON);
					case ACTION1 : return gamepad.justPressed(PS4ButtonID.SQUARE_BUTTON);
					case ACTION2 : return gamepad.justPressed(PS4ButtonID.TRIANGLE_BUTTON);
					case ACTION3 : return gamepad.justPressed(PS4ButtonID.CIRCLE_BUTTON);
					case START   : return gamepad.justPressed(7) || gamepad.justPressed(PS4ButtonID.START_BUTTON);
				}
		}
		return false;
	}
}