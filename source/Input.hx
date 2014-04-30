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

	public static var gamepads:Array<FlxGamepad> = new Array<FlxGamepad>();

	public static function getActiveGamepads():Void
	{
		gamepads = FlxG.gamepads.getActiveGamepads();
	}

	public static function isPressing(Action:Int, Number:Int):Bool
	{
		var style = Reg.SINGLE_PLAYER_MODE ? Reg.SINGLE_PLAYER_CONTROLSTYLE : Reg.ControlStyles[Number];
		// If there is no corresponding gamepad, default to keyboard
		if (gamepads.length <= Number)
			style = Keyboard;
		switch (style) {
			case Keyboard:
				return FlxG.keys.anyPressed([Reg.KeyboardControls[Number][Action]]);
			case Gamepad:
				if (gamepads.length <= Number) return false; // redundant line to prevent crashing without disabling gamepad just in case
				switch (Action) {
					case UP      : return gamepads[Number].getXAxis(1) == -1 || gamepads[Number].dpadUp;
					case DOWN    : return gamepads[Number].getXAxis(1) ==  1 || gamepads[Number].dpadDown;
					case LEFT    : return gamepads[Number].getXAxis(0) == -1 || gamepads[Number].dpadLeft;
					case RIGHT   : return gamepads[Number].getXAxis(0) ==  1 || gamepads[Number].dpadRight;
					case JUMP    : return gamepads[Number].pressed(PS4ButtonID.X_BUTTON);
					case ACTION1 : return gamepads[Number].pressed(PS4ButtonID.SQUARE_BUTTON);
					case ACTION2 : return gamepads[Number].pressed(PS4ButtonID.TRIANGLE_BUTTON);
					case ACTION3 : return gamepads[Number].pressed(PS4ButtonID.CIRCLE_BUTTON);
					case START   : return gamepads[Number].pressed(7) || gamepads[Number].pressed(PS4ButtonID.START_BUTTON);
				}
		}
		return false;
	}

	public static function isJustPressing(Action:Int, Number:Int):Bool
	{
		var style = Reg.SINGLE_PLAYER_MODE ? Reg.SINGLE_PLAYER_CONTROLSTYLE : Reg.ControlStyles[Number];
		// If there is no corresponding gamepad, default to keyboard
		if (gamepads.length <= Number)
			style = Keyboard;
		switch (style) {
			case Keyboard:
				return FlxG.keys.anyJustPressed([Reg.KeyboardControls[Number][Action]]);
			case Gamepad:
				if (gamepads.length <= Number) return false; // redundant line to prevent crashing without disabling gamepad just in case
				switch (Action) {
					case UP      : return gamepads[Number].getXAxis(1) == -1 || gamepads[Number].dpadUp;
					case DOWN    : return gamepads[Number].getXAxis(1) ==  1 || gamepads[Number].dpadDown;
					case LEFT    : return gamepads[Number].getXAxis(0) == -1 || gamepads[Number].dpadLeft;
					case RIGHT   : return gamepads[Number].getXAxis(0) ==  1 || gamepads[Number].dpadRight;
					case JUMP    : return gamepads[Number].justPressed(PS4ButtonID.X_BUTTON);
					case ACTION1 : return gamepads[Number].justPressed(PS4ButtonID.SQUARE_BUTTON);
					case ACTION2 : return gamepads[Number].justPressed(PS4ButtonID.TRIANGLE_BUTTON);
					case ACTION3 : return gamepads[Number].justPressed(PS4ButtonID.CIRCLE_BUTTON);
					case START   : return gamepads[Number].justPressed(7) || gamepads[Number].justPressed(PS4ButtonID.START_BUTTON);
				}
		}
		return false;
	}
}