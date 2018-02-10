package ;

import PlayState;
import flixel.FlxG;
import PlayState.Team;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.addons.effects.FlxTrail;


/**
 * ボール
 **/
class Ball extends FlxSprite {

  static inline var GRAVITY:Float = 100.0;
  static inline var BOUND_V:Float = 0.1;

  public var team:Team = Team.None;
  public var keep:Bool = false;
  public var hold:Bool = false;
  var _touchID:Int = -1;
  var _touchX:Float = 0.0;
  var _touchY:Float = 0.0;
  var _power:Float = 0.0;
  var _score:Int = 1;
  var _trail:FlxTrail;

  public function getTouchID():Int {
    return _touchID;
  }

  public function getTrail():FlxTrail {
    return _trail;
  }

  public function new() {
    super();

    var no = FlxG.random.int(1, 4);
    var str = 'assets/images/${no}.png';
    loadGraphic(str);

    // トレイル
    _trail = new FlxTrail(this, null, 5);
  }

  public function create(X:Float, Y:Float):Void {
    x = X;
    y = Y;

    velocity.x = FlxG.random.float(-100, 100);
    velocity.y = FlxG.random.float(-100, 100);
  }

  override public function update(dt:Float):Void {
    super.update(dt);

    color = FlxColor.WHITE;
    switch(team) {
      case Team.None:
        color = FlxColor.WHITE;
      case Team.Red:
        color = 0xffFF8080;
      case Team.Blue:
        color = 0xff8080FF;
    }
    if(hold) {
      var vx = _touchX - (x + width/2);
      var vy = _touchY - (y + height/2);
      var div = 10;
      vx *= 60 / div;
      vy *= 60 / div;
      velocity.set(vx, vy);
      color = FlxColor.interpolate(color, FlxColor.WHITE, FlxG.random.float(0, 1));
    }

    // 上下左右の反発力
    _boundWall();

    // 重力の設定
    _setGravity();
  }

  /**
   * タッチ情報を設定
   **/
  public function touch(id:Int, touchX:Float, touchY:Float):Void {
    _touchID = id;
    _touchX  = touchX;
    _touchY  = touchY;
    hold = true;
    keep = true;

    if(team != Team.None) {
      if(y < FlxG.height/2) {
        team = Team.Red;
      }
      else {
        team = Team.Blue;
      }
    }
  }

  /**
   * ホールド解除
   **/
  public function release():Void {
    hold = false;
    keep = false;
  }

  /**
   * 消滅
   **/
  public function vanish():Void {
    var state = cast(FlxG.state, PlayState);
    var px = x + width/2;
    var py = y + height/2;
    state.addParticleBroken(team, px, py);
    kill();
    _trail.kill(); // トレイルも一緒に消す

    Snd.playSe("damage");
  }

  /**
   * 上下の壁に衝突
   **/
  function _collideVerticalWall(team:Team, bBreak:Bool):Void {
    var state = cast(FlxG.state, PlayState);
    var px = x + width/2;
    var py = y + height/2;
    state.addParticle(team, px, py);
    if(bBreak) {
      state.addParticleBroken(team, px, py);
      state.addScore(team, _score);
      vanish();
    }
    else {
      Snd.playSe("change");
    }
  }

  /**
   * 壁で跳ね返る
   **/
  function _boundWall():Void {
    if(x < 0) {
      x = 0; velocity.x *= -1;
    }
    if(y < PlayState.V_MARGIN) {
      // 赤チーム
      y = PlayState.V_MARGIN + 1; velocity.y *= -BOUND_V;
      if(team == Team.Blue) {
        _collideVerticalWall(team, true);
      }
      else if(team == Team.None) {
        _collideVerticalWall(team, false);
      }
      team = Team.Red;
    }
    if(x > FlxG.width-width) {
      x = FlxG.width-width; velocity.x *= -1;
    }
    if(y > FlxG.height-height-PlayState.V_MARGIN) {
      // 青チーム
      y = FlxG.height-height-PlayState.V_MARGIN-1; velocity.y *= -BOUND_V;
      if(team == Team.Red) {
        _collideVerticalWall(team, true);
      }
      else if(team == Team.None) {
        _collideVerticalWall(team, false);
      }
      team = Team.Blue;
    }
  }

  /**
   * 重力の設定
   **/
  function _setGravity():Void {
    if(y+height/2 < FlxG.height/2) {
      acceleration.y = -GRAVITY;
    }
    else {
      acceleration.y = GRAVITY;
    }
  }
}

