package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.input.gamepad.PS4ButtonID;
import flixel.system.replay.FlxReplay;
import flixel.text.FlxText;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	private var _backdropsFar:Backdrops;
	private var _backdropsMid:Backdrops;
	private var _backdropsNear:Backdrops;
	private var _buildings:RandomBuildings = new RandomBuildings();
	private var _leafEmitter:LeafEmitter = new LeafEmitter();
	private var _players:Array<Player> = new Array();
	private var _replay:FlxReplay;
	private var choosePlayers:FlxText;
	private var names:FlxText;

	private var _numPlayers = 2;
	private var _twoPlayers:FlxText;
	private var _threePlayers:FlxText;
	private var _fourPlayers:FlxText;

	// Hack to get dpad working for selections
	private var _prvDpadLefts  = false;
	private var _curDpadLefts  = false;
	private var _prvDpadRights = false;
	private var _curDpadRights = false;

	private var _timer = 0.0;
	private var _timeLimit = 90;

	override public function create():Void
	{
		super.create();

		FlxG.mouse.visible = false;

		FlxG.sound.playMusic("music", 0.35, true);

		// Set a background color
		FlxG.cameras.bgColor = 0xff4a9294;

		_backdropsFar = new Backdrops(this, Reg.BACKDROPSFAR);

		// Create the random buildings
		_buildings.init(-1, Reg.LEVELLENGTH * 2);
		add(_buildings);

		var startX = Math.round(FlxG.width/2);
		var startY = 0;
		for (i in 0...Reg.MAX_PLAYERS) {
			var p = new Player(startX, startY, i);
			p.autoscrollMonkey = true;
			_players.push(p);

			// Adjust up and left for next monkey
			startX -= FlxRandom.intRanged(0, Math.round(FlxG.width/8));
			startY -= FlxRandom.intRanged(0, Math.round(FlxG.width/8));
		}

		// Add to the scene in reverse order
		var i = Reg.MAX_PLAYERS;
		while (--i >= 0) {
			add(_players[i]);
		}

		_backdropsMid = new Backdrops(this, Reg.BACKDROPSMID);

		_leafEmitter.init();
		add(_leafEmitter);
		
		_backdropsNear = new Backdrops(this, Reg.BACKDROPSNEAR);

    var title = new FlxText(0, 80, FlxG.width, "CONCRETE JUNGLE");
    title.size = 40;
    title.color = 0xff111112;
    title.alignment = "center";
    add(title);
    title.scrollFactor.x = 0;

    choosePlayers = new FlxText(0, FlxG.height/2 + 50, FlxG.width, "Choose Number of Players");
    choosePlayers.alignment = "center";
    choosePlayers.color = 0xff111112;
    add(choosePlayers);
    choosePlayers.scrollFactor.x = 0;

    // Three is centered -- other two are spread
    var textSpread = 40;

    _threePlayers = new FlxText(0, FlxG.height/2 + 10, FlxG.width, "3");
    _threePlayers.size = 32;
    _threePlayers.alignment = "center";
    _threePlayers.scrollFactor.x = 0;
    add(_threePlayers);

    _twoPlayers = new FlxText(-textSpread, FlxG.height/2 + 10, FlxG.width, "2");
    _twoPlayers.size = 32;
    _twoPlayers.scrollFactor.x = 0;
    _twoPlayers.alignment = "center";
    add(_twoPlayers);

    _fourPlayers = new FlxText(textSpread, FlxG.height/2 + 10, FlxG.width, "4");
    _fourPlayers.size = 32;
    _fourPlayers.scrollFactor.x = 0;
    _fourPlayers.alignment = "center";
    add(_fourPlayers);

    names = new FlxText(0, FlxG.height - 16, FlxG.width,"Ian Clarkson   +   Steven Circuiton   +   Colin Marjoram");
    names.color = 0xffffffff;
    names.size = 8;
    names.scrollFactor.x = 0;
    names.alignment = "center";
    add(names);

    // Make sure setBounds comes before follow, otherwise follow doesn't work!
    FlxG.camera.flash(0xff111112, 2.5);
		FlxG.camera.setBounds(0, 0, Reg.LEVELLENGTH * 2, FlxG.height);
		FlxG.camera.follow(_players[0], FlxCamera.STYLE_PLATFORMER, new FlxPoint(50, 0), 4);

	}

	override public function update():Void
	{
		FlxG.worldBounds.set(FlxG.camera.scroll.x - 20, FlxG.camera.scroll.y - 20, FlxG.width + 20, FlxG.height + 20);

		_timer += FlxG.elapsed;
		if (_timer > _timeLimit) {
			_timer = 0;
			resetState();
		}

		_curDpadLefts  = Input.isJustPressing(Input.LEFT,0);
		_curDpadRights = Input.isJustPressing(Input.RIGHT,0);

		var dpadLeftJustPressed  = _curDpadLefts  && !_prvDpadLefts;
		var dpadRightJustPressed = _curDpadRights && !_prvDpadRights;

		if (dpadLeftJustPressed) {
			_numPlayers = _numPlayers > 2 ? _numPlayers - 1 : Reg.MAX_PLAYERS;
		} else if (dpadRightJustPressed) {
			_numPlayers = _numPlayers < Reg.MAX_PLAYERS ? _numPlayers + 1 : 2;
		}

    _twoPlayers.color   = _numPlayers == 2 ? 0xffffffff : 0xff111112;
    _threePlayers.color = _numPlayers == 3 ? 0xffffffff : 0xff111112;
    _fourPlayers.color  = _numPlayers == 4 ? 0xffffffff : 0xff111112;

    // START THE GAME!
		if (Input.isJustPressing(Input.JUMP,0) || Input.isJustPressing(Input.ACTION1,0) || Input.isJustPressing(Input.ACTION2,0) || Input.isJustPressing(Input.ACTION3,0)) {
			onSelectionMade();	
		}

		for (p in _players) {
			FlxG.collide(p, _buildings);
		}

		_prvDpadLefts  = _curDpadLefts;
		_prvDpadRights = _curDpadRights;

    super.update();
	}	

	private function onSelectionMade():Void
	{
		FlxG.cameras.fade(0xffffffff, 2, false, onDemoFaded);
	}
	
	private function onDemoFaded():Void
	{
		FlxG.switchState(new PlayState(_numPlayers));	
	}

	private function resetState():Void
	{
		FlxG.cameras.fade(0xff111112, 2, false, onResetFaded);	
	}

	private function onResetFaded():Void
	{
		FlxG.resetState();
	}

}