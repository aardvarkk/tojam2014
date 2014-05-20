package;

class Reg
{
	// Maximum number of players allowed in the game
	public static inline var MAX_PLAYERS = 4;

	// How long a game round is (horizontally in pixels)
	public static inline var LEVELLENGTH = 2048 * 4;

	// General unit size (size of level block features)
	public static inline var BLOCKSIZE = 16; 

	// Used to control all players with 1 gamepad / key set by switching between them
	public static inline var SINGLE_PLAYER_MODE = false;
	// Used to override the normal controls when testing with one input
	public static var SINGLE_PLAYER_CONTROLSTYLE = ControlStyle.Gamepad;

	public static inline var RACERWIDTH  = 48;
	public static inline var RACERHEIGHT = 16;
	public static inline var RACERSPEED  = 75;

	public static inline var START_X     = 64;
	public static inline var START_Y     = 0;

	public static inline var DEMOSEED    = 635918;

	// Controls used for each player
	// Defaults back to keyboard if there is no gamepad
	// Ideally later it'll give the first available keyset to the first player who needs it
	// IE giving keyset 0 to player 2 if player 0 and 1 already have gamepads
	public static var ControlStyles:Array<ControlStyle> =
	[
		Gamepad,
		Gamepad,
		Gamepad,
		Gamepad
	];

	// null means we'll use a gamepad for this player slot, otherwise we'll use the given keyboard controls
	public static var KeyboardControls:Array<Dynamic> =
	[
		["UP", "DOWN", "LEFT", "RIGHT", "Z", "X", "C", "V", "ENTER"],
		//["NUMPADFIVE","NUMPADTWO","NUMPADONE","NUMPADTHREE","NUMPADSEVEN","NUMPADEIGHT","NUMPADNINE","NUMPADMINUS", "ENTER"],
		["UP", "DOWN", "LEFT", "RIGHT", "Z", "X", "C", "V", "ENTER"],
		["W", "S", "A", "D", "R", "T", "Y", "U", "ENTER"],
		["I","K","J","L","O","P","SEMICOLON","QUOTE", "ENTER"]
	];

	public static var BACKDROPSFAR:Array<Dynamic> = [
		["images/cloudsFar.png", 0.125, null],
		["images/cloudsMid.png", 0.25, null],
		["images/cloudsNear.png", 0.5, null],
		["images/mountainsFar.png", 0.1, 180],
		["images/buildingsMid.png", 0.2, 128],
		["images/buildingsNear.png", 0.4, 80],
		["images/mist.png", 0.45, 138]
	];

	public static var BACKDROPSMID:Array<Dynamic> = [
		["images/mist2.png", 1.15, 98]
	];

	public static var BACKDROPSNEAR:Array<Dynamic> = [
		["images/jungleforeground.png", 1.3, null],
		["images/jungleforegroundbot.png", 1.3, 48]
	];

	public static var MONKEYS:Array<String> = [
		"images/monkey.png",
		"images/monkey2.png",
		"images/monkey3.png",
		"images/monkey4.png"
	];

	public static inline var BUBBLE = "images/bubble.png";
	public static inline var HANDS = "images/hand.png";
	public static inline var CROSSHAIR = "images/crosshair.png";
	public static inline var LEAVES = "images/leaves02.png";
	public static inline var BANANA = "images/banana.png";
	public static inline var BOMB = "images/bomb.png";
	public static inline var MISSILE = "images/missile.png";
	public static inline var MISSILE_BLAST = "images/stinkbomb.png";
	public static inline var BOMB_BLAST = "images/explosion1.png";
	public static inline var BANANA_BLAST = "images/bananapop.png";
	public static inline var LEVELTILES = "images/tiles.png";

	public static var scores:Array<Int> = [];

	public static function resetScores() 
	{
		scores = [];
	}

	public static function getScoreString()
	{
		// Space out the scores so the monkey sprites can fit in
		// Hacky, but it works!
		var scoreString = "";
		for (i in 0...scores.length)
		{
			var score = Reg.scores[i];
			scoreString += '    $score\n';
		}
		return scoreString;
	}

	public static function getWinner():Int
	{
		var maxScoreIdx = 0;
		var maxScore = scores[0];
		for (i in 1...scores.length) 
		{
			if (scores[i] > maxScore) {
				maxScore = scores[i];
				maxScoreIdx = i;
			}
		}
		return maxScoreIdx;
	}

}