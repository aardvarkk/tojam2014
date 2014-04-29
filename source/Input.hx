package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.XboxButtonID;
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

	static public inline var UP      :Int = 0;
	static public inline var DOWN    :Int = 1;
	static public inline var LEFT    :Int = 2;
	static public inline var RIGHT   :Int = 3;
	static public inline var JUMP    :Int = 4;
	static public inline var ACTION1 :Int = 5;
	static public inline var ACTION2 :Int = 6;
	static public inline var ACTION3 :Int = 7;

	static public var gamepads:Array<FlxGamepad> = new Array<FlxGamepad>();

	static public function isPressing(Action:Int, Number:Int):Bool
	{
		var style = Reg.SinglePlayerMode ? ControlStyle.Keyboard : Reg.ControlStyles[Number];
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

	static public function isJustPressing(Action:Int, Number:Int):Bool
	{
		var style = Reg.SinglePlayerMode ? ControlStyle.Keyboard : Reg.ControlStyles[Number];
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