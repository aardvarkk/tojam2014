package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxRandom;
import flixel.addons.display.FlxExtendedSprite;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxPoint;

class Player extends FlxExtendedSprite
{
	public var attacking = false;
	public var attackTimer = 0.0;
	public var ATTACKDELAY = 0.5;
	public var autoscrollMonkey = false;
	public var bubble:Bubble;
	public var climbing = false;
	public var controlSet = 0;
	public var deathTimer = 0.0;
	public var respawnTimer = 0.0;
	public var diving = false;
	public var gravity = 450.0;
	public var invulnerable = false;
	public var number = -1;
	public var ridingVehicle = false;
	public var selected = false;

	// Don't allow input while frozen
	// Useful for countdown so nobody moves
	public var frozen = false;

	private var _vehicle:FlxSprite;
	private var _jumpTimer = 0.0;
	private var _jumpStrength = 136.0;
	private var _runAccel = 900;
	private var _diveBombMaxVelocityMult = 3; // Multiplier to max velocity
	private var _diveBombBoostX = 300; // Instant boost to velocity in X
	private var _diveBombSetVelY = 100; // Instant set to velocity in Y
	private var _bombs:FlxTypedGroup<Bomb>;
	private var _bananas:FlxTypedGroup<Banana>;
	private var _missiles:FlxTypedGroup<Missile>;
	private var _invTimer = 0.8;
	private var _invDuration = 0.8;
	private var _aim = 180.0;
	private var _crosshair:Crosshair;
	private var _jumpStrings = ["LightOoh", "TinyOoh1", "TinyOoh2", "TinyOoh3", "TinyOoh4", "TinyOoh5", "TinyOoh6", "TinyOoh7", "TinyOoh8", "TinyOoh9"];
	private var _deathStrings = ["Megascreech1", "Megascreech2", "Megascreech3", "Squak"];
	private var _autoJumpTimer = 0.0;
	private var _autoJumpDelay = 0.1;
	private var _jumpHold = false;

	public function new(
		X:Int, 
		Y:Int, 
		Number:Int, 
		?Bombs:FlxTypedGroup<Bomb>, 
		?Bananas:FlxTypedGroup<Banana>, 
		?Missiles:FlxTypedGroup<Missile>
		)
	{
		super(X, Y);

		number = Number;
		_bombs = Bombs; // ref to the bomb group
		_bananas = Bananas;
		_missiles = Missiles;

		loadGraphic(Reg.MONKEYS[number], true, 16, 16);

		bubble = new Bubble(X, Y);

		width = 10;
		height = 13;
		offset.x = 3;
		offset.y = 3;

		animation.add("idle", [0, 1, 2, 3], 6, true);
		animation.add("walk", [4, 5, 6], 12, true);	
		animation.add("jump", [9, 10, 11, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12], 8, true);
		animation.add("fall", [12], 8, true);
		animation.add("climb", [11, 12], 8, true);
		animation.add("climbidle", [8], 4, true);
		animation.add("attack", [10], 4, false);

		reset(X, Y);
	}

	override public function update():Void
	{
		animate();

		if (ridingVehicle) {
			x = _vehicle.x + 12;
			y = _vehicle.y;
			_crosshair.angle = _aim;
			_crosshair.x = x + width / 2;
			_crosshair.y = y + height / 2;
			
			if (attackTimer > 0) {
				attackTimer -= FlxG.elapsed;
			}

			if (!frozen) {
				if (selected) {
					ridingControls();
				} else if (autoscrollMonkey) {
					cpuMonkeyDefend();
				}
			}
		} else {
			if (!frozen) {
				if (selected) {
					movingControls();
				} else if (autoscrollMonkey) {
					cpuMonkeyAssault();
				}
			}
		}

		// If user is still holding the jump (or it's a bot), do variable jump control
		_jumpHold = _jumpHold && (autoscrollMonkey || Input.isPressing(Input.JUMP, (Reg.SINGLE_PLAYER_MODE) ? 0 : number));
		if (_jumpHold) {
			_jumpTimer += FlxG.elapsed;

			if (_jumpTimer < 0.075) {
				velocity.y = -_jumpStrength * 0.7;
			} else if (_jumpTimer < 0.15) {
				velocity.y = -_jumpStrength * 1;
			} else if (_jumpTimer < 0.24) {
				velocity.y = -_jumpStrength * 1.1;
			} else if (_jumpTimer >= 0.26 ) {
				_jumpHold = false;
				_jumpTimer = 0;
			}
		}

		// Landing
		if (justTouched(FlxObject.FLOOR)) {
			FlxG.sound.play("Landing", 0);			
		}

		// Respawn stuff
		// When it was >= 0 there were bugs
		if (respawnTimer > 0) {
			respawnTimer -= FlxG.elapsed;
			velocity.y = 0;
			bubble.x = x - 10;
			bubble.y = y - 12;

			// Kill bubble
			if (Input.isPressing(Input.JUMP, number) || x > FlxG.camera.scroll.x + 100 || respawnTimer <= 0) {
				respawnTimer = -1;
				bubble.die();
			}
		}

		super.update();		
	}

	override public function reset(X:Float, Y:Float):Void
	{
		super.reset(X, Y);

		acceleration.y = gravity;
		diving = false;
		drag.x = gravity; // Ground friction
		health = 1;
		maxVelocity.x = Reg.RACERSPEED * 2.25;
		maxVelocity.y = 2 * gravity; 
		solid = true;
	}

	override public function kill():Void
	{
		super.kill();
		deathTimer = 1;
		FlxG.sound.play(_deathStrings[FlxRandom.intRanged(0, _deathStrings.length-1)], 0.25);
	}

	public function cpuMonkeyAssault():Void
	{
		acceleration.x = _runAccel * 0.75;
		facing = FlxObject.RIGHT;
		flipX  = false;

		// Constantly climb right walls
		if (isTouching(FlxObject.RIGHT)) {
			wallJump();
		}

		// Randomly jump on floors
		_autoJumpTimer -= FlxG.elapsed;
		if (_autoJumpTimer < 0 && isTouching(FlxObject.FLOOR) && FlxRandom.intRanged(0,9) == 9) {
			jump();
			_autoJumpTimer = _autoJumpDelay;
		}

		if (y > FlxG.height) {
			y = -50;
			x -= 50;
			FlxG.sound.play("LightOoh");
		}

		if (x > FlxG.camera.scroll.x + FlxG.width || x < FlxG.camera.scroll.x) {
			y = -50;
			x = FlxG.camera.scroll.x + 50;
		}
	}

	public function cpuMonkeyDefend():Void
	{
		if (attackTimer <= 0)
		{
			_aim = FlxRandom.intRanged(150,220);
			
			var r = FlxRandom.intRanged(0,2);

			if (r == 0) {
				_bombs.recycle(Bomb,[],true,false).shoot(this, _aim);
			} else if (r == 1) {
				_bananas.recycle(Banana,[],true,false).shoot(this, _aim);
			} else {
				_missiles.recycle(Missile,[],true,false).shoot(this, _aim);
			}

			attackTimer = ATTACKDELAY;
		}
	}

	public function ridingControls():Void
	{
		var controlNumber = (Reg.SINGLE_PLAYER_MODE) ? 0 : number;
		if (Reg.SINGLE_PLAYER_MODE && !selected) {
			return;
		}

		_vehicle.acceleration.y = 0;

		if (Input.isPressing(Input.UP, controlNumber) && (_vehicle.y + _vehicle.height/2 > FlxG.height/2)) {
			_vehicle.acceleration.y -= _runAccel * .25;
		} else if (Input.isPressing(Input.DOWN, controlNumber) && (_vehicle.y + _vehicle.height < FlxG.height)) {
			_vehicle.acceleration.y += _runAccel * .25;
		}

		if (Input.isPressing(Input.LEFT, controlNumber)) {
			_aim -= 4;
		} else if (Input.isPressing(Input.RIGHT, controlNumber)) {
			_aim += 4;
		}

		if (_vehicle.y + _vehicle.height/2 < FlxG.height/2) {
			_vehicle.velocity.y = 0;
			_vehicle.acceleration.y = 0;
			_vehicle.y = FlxG.height/2 - _vehicle.height/2;
		} else if (_vehicle.y + _vehicle.height > FlxG.height) {
			_vehicle.velocity.y = 0;
			_vehicle.acceleration.y = 0;
			_vehicle.y = FlxG.height - _vehicle.height;
		}

		if (attackTimer <= 0) {
			if (Input.isPressing(Input.ACTION1, controlNumber)) {
				FlxG.log.add("Shot a bomb!");
				_bombs.recycle(Bomb,[],true,false).shoot(this, _aim);
				attackTimer = ATTACKDELAY;
			} else if (Input.isPressing(Input.ACTION2, controlNumber)) {
				FlxG.log.add("Shot a boomerang!");
				_bananas.recycle(Banana,[],true,false).shoot(this, _aim);
				attackTimer = ATTACKDELAY;
			} else if (Input.isPressing(Input.ACTION3, controlNumber)) {
				FlxG.log.add("Shot a missile!");
				_missiles.recycle(Missile,[],true,false).shoot(this, _aim);
				attackTimer = ATTACKDELAY;
			}
		}
	}

	public function movingControls():Void
	{
		if (Reg.SINGLE_PLAYER_MODE && !selected) {
			return;
		}

		var controlNumber = (Reg.SINGLE_PLAYER_MODE) ? 0 : number;

		acceleration.x = 0;

		// Move Left
		if (Input.isPressing(Input.LEFT, controlNumber)) {
			flipX = true;
			facing = FlxObject.LEFT;
			acceleration.x -= _runAccel;
		}
		
		// Move Right
		if (Input.isPressing(Input.RIGHT, controlNumber)) {
			flipX = false;
			facing = FlxObject.RIGHT;
			acceleration.x += _runAccel;
		}
		
		// Divebomb, jumping
		if (Input.isJustPressing(Input.JUMP, controlNumber)) {
			// Dive bomb
			if (!diving && Input.isPressing(Input.DOWN, controlNumber)) {
				FlxG.sound.play("Divebomb", 0.25);
				diving = true;
				velocity.x += _diveBombBoostX;
				velocity.y = _diveBombSetVelY;
				maxVelocity.x *= _diveBombMaxVelocityMult;
				maxVelocity.y *= _diveBombMaxVelocityMult;
			} else if (isTouching(FlxObject.FLOOR)) {
				// Normal jump
				jump();
			}
		}

		// Walljumping possible even if you're already holding down jump
		if (Input.isPressing(Input.JUMP, controlNumber) && isTouching(FlxObject.WALL)) {
			// Wall jump
			wallJump();
		}
	}

	public function wallJump()
	{
		_jumpTimer = 0;
		_jumpHold  = true;

		// Wall kickback
		velocity.x = (facing == FlxObject.LEFT) ? 100 : -100;
	}

	public function jump()
	{
		_jumpTimer = 0;
		_jumpHold  = true;

		// Jump sound
		FlxG.sound.play(_jumpStrings[FlxRandom.intRanged(0, _jumpStrings.length-1)]);
	}
	
	public function animate():Void
	{
		animation.play("idle");

		if (!ridingVehicle)	{
			if (velocity.y > 0)	{
				animation.play("fall");
			}
			else if (velocity.y < 0) {
				animation.play("jump");
			} else if (velocity.x != 0){
				animation.play("walk");
			}
		}
	}

	public function respawn(X:Float, Y:Float):Void
	{
		reset(X, Y);

		bubble.reset(x - 10, y - 12);
		respawnTimer = 2;
	}

	public function mount(Vehicle:FlxSprite, Aimer:Crosshair):Void
	{
		ridingVehicle = true;
		acceleration.y = 0;
		velocity.x = 0;
		velocity.y = 0;
		facing = FlxObject.LEFT;
		flipX = true;
		solid = false;
		_crosshair = Aimer;
		_vehicle = Vehicle;
	}

	public function dismount():Void
	{
		ridingVehicle = false;
		acceleration.y = gravity;
		solid = true;
		x = 0;
		y = 0;
		_vehicle = null;
		_crosshair = null;

		kill();
	}
}