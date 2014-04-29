package;

import flixel.FlxG;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.PS4ButtonID;

class Input
{
	// For the sufami controllers, ABXY is the same as PS4 placement
	// but the dpad is AxisX(0) for left (-1) and right (1)
	// and AxisX(1) for up (-1) and down (1) where 0 is no input
	// Forgot to commit two things separately so added this so I could make a new commit
	// Added support for the USB controllers I have
	// which use AxisX(0) for dpad X
	// and AxisX(1) for dpad Y

	public static inline var UP      = 0;
	public static inline var DOWN    = 1;
	public static inline var LEFT    = 2;
	public static inline var RIGHT   = 3;
	public static inline var JUMP    = 4;
	public static inline var ACTION1 = 5;
	public static inline var ACTION2 = 6;
	public static inline var ACTION3 = 7;

	public static var gamepads:Array<FlxGamepad> = new Array<FlxGamepad>();

	public static function isPressing(Action:Int, Number:Int):Bool
	{
		var style = Reg.SINGLE_PLAYER_MODE ? ControlStyle.Keyboard : Reg.ControlStyles[Number];
		switch (style) {
			case Keyboard:
				return FlxG.keys.anyPressed([Reg.KeyboardControls[Number][Action]]);
			case Gamepad:
				return false;
				switch (Action) {
					case UP      : return gamepads[Number].getXAxis(1) == -1 || gamepads[Number].dpadUp;
					case DOWN    : return gamepads[Number].getXAxis(1) ==  1 || gamepads[Number].dpadDown;
					case LEFT    : return gamepads[Number].getXAxis(0) == -1 || gamepads[Number].dpadLeft;
					case RIGHT   : return gamepads[Number].getXAxis(0) ==  1 || gamepads[Number].dpadRight;
					case JUMP    : return gamepads[Number].pressed(PS4ButtonID.X_BUTTON);
					case ACTION1 : return gamepads[Number].pressed(PS4ButtonID.SQUARE_BUTTON);
					case ACTION2 : return gamepads[Number].pressed(PS4ButtonID.TRIANGLE_BUTTON);
					case ACTION3 : return gamepads[Number].pressed(PS4ButtonID.CIRCLE_BUTTON);
				}
		}
		return false;
	}

	public static function isJustPressing(Action:Int, Number:Int):Bool
	{
		var style = Reg.SINGLE_PLAYER_MODE ? ControlStyle.Keyboard : Reg.ControlStyles[Number];
		switch (style) {
			case Keyboard:
				return FlxG.keys.anyJustPressed([Reg.KeyboardControls[Number][Action]]);
			case Gamepad:
				return false;
				switch (Action) {
					case UP      : return gamepads[Number].getXAxis(1) == -1 || gamepads[Number].dpadUp;
					case DOWN    : return gamepads[Number].getXAxis(1) ==  1 || gamepads[Number].dpadDown;
					case LEFT    : return gamepads[Number].getXAxis(0) == -1 || gamepads[Number].dpadLeft;
					case RIGHT   : return gamepads[Number].getXAxis(0) ==  1 || gamepads[Number].dpadRight;
					case JUMP    : return gamepads[Number].justPressed(PS4ButtonID.X_BUTTON);
					case ACTION1 : return gamepads[Number].justPressed(PS4ButtonID.SQUARE_BUTTON);
					case ACTION2 : return gamepads[Number].justPressed(PS4ButtonID.TRIANGLE_BUTTON);
					case ACTION3 : return gamepads[Number].justPressed(PS4ButtonID.CIRCLE_BUTTON);
				}
		}
		return false;
	}
}