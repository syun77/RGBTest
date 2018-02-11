package;

import flixel.group.FlxSpriteGroup;
import ParticleBroken.ParticleBrokenMgr;
import Particle.ParticleMgr;
import PlayState.Team;
import flixel.tweens.FlxEase;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.math.FlxVector;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

enum Team {
  None;
  Red;
  Blue;
}

enum State {
  Title; // タイトル画面
  Ready; // ゲーム開始前のカウントダウン
  MainGame; // メインゲーム
  Result; // リザルト
}

/**
 * メインゲーム
 **/
class PlayState extends FlxState {

  public static inline var V_MARGIN:Int = 64; // 上下のマージン
  static inline var TIME_LIMIT:Int = 60; // 制限時間
  static inline var TIMER_SCORE:Int = 30; // スコア加算演出用タイマー
  static inline var BASE_BALL_COUNT:Int = 4; // ボールの基本数
  static inline var MAX_BALL_COUNT:Int = 32; // ボールの最大数
  static inline var TIMER_DELAY:Float = 2.0;

  var _state:State = State.Title;
  var _trails:FlxSpriteGroup;
  var _balls:FlxTypedGroup<Ball>;
  var _particles:ParticleMgr;
  var _particleBrokens:ParticleBrokenMgr;
  var _scoreRed:Int = 0;
  var _scoreBlue:Int = 0;
  var _time:Float = 0.0;
  var _maxBallCount:Int = BASE_BALL_COUNT; // 最大のボール数
  var _sideTeam:Team = Team.Red; // どちらのチームに登場させたか
  var _timerDelay:Float = 0;

  // 演出
  var _timerRed:Int = 0;
  var _timerBlue:Int = 0;

  // UI
  var _txtRedScore:FlxText;
  var _txtBlueScore:FlxText;
  var _txtTimer:FlxText;
  var _txtCaption:FlxText;
  var _bgCaption:FlxSprite;
  var _btn:FlxButton;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    {
      var bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, Math.floor(FlxG.height/2), 0xff400000);
      this.add(bg);
      var bg2 = new FlxSprite(0, 0).makeGraphic(FlxG.width, V_MARGIN, 0xFFFF0000);
      this.add(bg2);
    }
    {
      var bg = new FlxSprite(0, FlxG.height/2).makeGraphic(FlxG.width, Math.floor(FlxG.height/2), 0xff000040);
      this.add(bg);
      var bg2 = new FlxSprite(0, FlxG.height-V_MARGIN).makeGraphic(FlxG.width, V_MARGIN, 0xFF0000FF);
      this.add(bg2);
    }
    {
      _txtRedScore = new FlxText(0, FlxG.height/5, FlxG.width, "", 96);
      _txtRedScore.alignment = FlxTextAlign.CENTER;
      _txtRedScore.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;
      _txtRedScore.borderSize = 8;
      this.add(_txtRedScore);
    }
    {
      _txtBlueScore = new FlxText(0, FlxG.height*2/3, FlxG.width, "", 96);
      _txtBlueScore.alignment = FlxTextAlign.CENTER;
      _txtBlueScore.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;
      _txtBlueScore.borderSize = 8;
      this.add(_txtBlueScore);
    }
    {
      _txtTimer = new FlxText(0, FlxG.height/2-24, FlxG.width, "", 48);
      _txtTimer.alignment = FlxTextAlign.CENTER;
      _txtTimer.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;
      _txtTimer.borderSize = 8;
      this.add(_txtTimer);
    }

    _trails = new FlxSpriteGroup();
    super.add(_trails);

    _balls = new FlxTypedGroup<Ball>();
    super.add(_balls);

    _particles = new ParticleMgr(8);
    super.add(_particles);
    _particleBrokens = new ParticleBrokenMgr(256);
    super.add(_particleBrokens);

    _txtCaption = new FlxText(0, FlxG.height/2-48, FlxG.width, "", 96);
    _txtCaption.alignment = FlxTextAlign.CENTER;
    _txtCaption.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;
    _txtCaption.borderSize = 8;
    _bgCaption = new FlxSprite(0, FlxG.height/2-60).makeGraphic(FlxG.width, 120, 0x80000000);
    _bgCaption.visible = false;
    this.add(_bgCaption);
    this.add(_txtCaption);


    _btn = new FlxButton(FlxG.width/2, FlxG.height/2, "START", function() {
      _state = State.Ready;
      _time = 3;
    });
    this.add(_btn);
  }

  function _startCaption(msg:String):Void {
    _txtCaption.text = msg;
    _txtCaption.visible = true;
    _bgCaption.visible = true;
  }
  function _endCaption():Void {
    _txtCaption.visible = false;
    _bgCaption.visible = false;
  }

  /**
   * スコアを加算する
   **/
  public function addScore(team:Team, val:Int):Void {
    if(team == Team.Red) {
      _scoreRed += val;
      _timerRed = TIMER_SCORE;
    }
    if(team == Team.Blue) {
      _scoreBlue += val;
      _timerBlue = TIMER_SCORE;
    }

  }

  public function addParticle(team:Team, x:Float, y:Float):Void {
    var p:Particle = _particles.recycle();
    p.revive();
    p.create(team, x, y);
  }

  public function addParticleBroken(team:Team, x:Float, y:Float):Void {
    // 画面を揺らす
    FlxG.camera.shake(0.03, 0.1);
    for(i in 0...32) {
      var p:ParticleBroken = _particleBrokens.recycle();
      p.create(team, x, y);
    }
  }

  /**
   * ゲーム開始
   **/
  function _startGame():Void {
    for(i in 0...MAX_BALL_COUNT) {
      var b = new Ball();
      b.ID = i;
      var x = (i%2) * FlxG.width/2 + FlxG.width/4;
      var y = Math.floor(i/2) * FlxG.height/2 + FlxG.height/4;
      b.create(x, y);
      _balls.add(b);
      _trails.add(b.getTrail());
      if(i >= _maxBallCount) {
        b.kill();
      }
    }

  }

  function _updateReady(elapsed:Float):Void {
    _btn.visible = false;
    var prev = _time;
    _time -= elapsed;
    for(i in 0...3) {
      if(_time < i && i < prev) {
        Snd.playSe("countdown");
      }
    }
    _startCaption('${Math.floor(_time) + 1}');
    if(_time < 0) {
      // ゲーム開始
      _startGame();
      _time = TIME_LIMIT;
      _endCaption();
      _state = State.MainGame;
      Snd.playSe("levelup");
    }
  }

  /**
   * リザルト開始
   **/
  function _startResult():Void {
    _time = 0;
    // リザルトへ
    _state = State.Result;
    Snd.playSe("levelup");
    if(_scoreRed > _scoreBlue) {
      // 赤組の勝利
      _startCaption("RED WIN");
    }
    else if(_scoreBlue > _scoreRed) {
      // 青組の勝利
      _startCaption("BLUE WIN");
    }
    else {
      // 引き分け
      _startCaption("The game was drawn");
    }
    var btn = new FlxButton(FlxG.width/2, FlxG.height/2 + 96, "END", function() {
      // ゲームをやり直す
      FlxG.resetGame();
    });
    this.add(btn);
  }

  /**
   * UIの更新
   **/
  function _updateUI():Void {
    _txtTimer.text = '${Math.floor(_time)}';

    if(_timerRed > 0) {
      _timerRed--;
      var t = FlxEase.expoIn(_timerRed / TIMER_SCORE);
      _txtRedScore.size = Math.floor(96 + t * _timerRed * 4);
      _txtRedScore.y = FlxG.height/5 - t * _timerRed *  4 / 2;
    }
    if(_timerBlue > 0) {
      _timerBlue--;
      var t = FlxEase.expoIn(_timerBlue / TIMER_SCORE);
      _txtBlueScore.size = Math.floor(96 + t * _timerBlue * 4);
      _txtBlueScore.y = FlxG.height*2/3 - t * _timerBlue * 4 / 2;
    }
    _txtRedScore.text = '${_scoreRed}';
    _txtBlueScore.text = '${_scoreBlue}';
  }

  function _checkAppearBall():Void {

    if(_timerDelay > 0) {
      _timerDelay -= FlxG.elapsed;
      return;
    }

    if(Math.floor(_time)%2 == 1) {
      return;
    }


    var cnt:Int = 0;
    _balls.forEachAlive(function(b:Ball) {
      cnt++;
    });

    var d = _maxBallCount - cnt;
    for(i in 0...d) {
      var b:Ball = _balls.recycle();
      b.revive();
      var px = FlxG.random.float(48, FlxG.width-48);
      var py = FlxG.height/4;
      if(_sideTeam == Team.Blue) {
        py += FlxG.height/2;
        _sideTeam = Team.Red;
      }
      else {
        _sideTeam = Team.Blue;
      }
      b.create(px, py);
      b.team = Team.None;

      // 連続で出現させない
      _timerDelay = TIMER_DELAY;
      break;
    }
  }

  /**
   * メインゲームの更新
   **/
  function _updateMain(elapsed:Float):Void {

    var prev = _time;
    _time -= elapsed;

    if(50 < prev && _time < 50 ) {
      _maxBallCount += 1;
    }
    if(40 < prev && _time < 40 ) {
      _maxBallCount += 1;
    }
    if(30 < prev && _time < 30 ) {
      _maxBallCount += 1;
    }
    if(20 < prev && _time < 20 ) {
      _maxBallCount += 1;
    }
    if(10 < prev && _time < 10 ) {
      _maxBallCount += 4;
    }
    for(i in 0...10) {
      if(_time < i && i < prev) {
        Snd.playSe("countdown");
      }
    }

    if(_time < 0) {
      // 時間切れの処理
      _startResult();
      return;
    }

    // ボールの出現チェック
    _checkAppearBall();

    // UIの更新
    _updateUI();

    FlxG.collide(_balls, _balls, _cbBallVsBall);

    _balls.forEachAlive(function(b:Ball):Void {
      b.keep = false;
    });

#if FLX_NO_TOUCH
    var touchX = FlxG.mouse.x;
    var touchY = FlxG.mouse.y;
    if(FlxG.mouse.justPressed) {
      _checkTouchBall(0, touchX, touchY);
    }
    else if(FlxG.mouse.pressed) {
      _keepTouchBall(0, touchX, touchY);
    }
#else
    for (touch in FlxG.touches.list) {
      var px = touch.x; // タッチ座標(X)を取得
      var py = touch.y; // タッチ座標(Y)を取得
      if (touch.justPressed) {
        // タッチした
        _checkTouchBall(touch.touchPointID, px, py);
      }
      else if(touch.pressed) {
        _keepTouchBall(touch.touchPointID, px, py);
      }
    }
    #end

    _balls.forEachAlive(function(b:Ball):Void {
      if(b.keep == false) {
        // キープされていなければホールド解除
        b.release();
      }
    });

  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    switch(_state) {
      case State.Title:

      case State.Ready:
        _updateReady(elapsed);

      case State.MainGame:
        _updateMain(elapsed);

      case State.Result:
    }

  }

  /**
   * ボールのつかみ判定
   **/
  function _checkTouchBall(id:Int, touchX:Float, touchY:Float):Void {

    var bFind:Bool = false;
    _balls.forEachAlive(function(b:Ball):Void {
      if(bFind) {
        return;
      }

      var MARGIN:Float = 32;
      if(b.x - MARGIN <= touchX && touchX <= b.x + b.width + MARGIN) {
        if(b.y - MARGIN <= touchY && touchY <= b.y + b.height + MARGIN) {
          if(b.hold == false) {
            // ホールド開始
            b.touch(id, touchX, touchY);
            bFind = true;
          }
        }
      }
    });
  }

  /**
   * ボールのキープ処理
   **/
  function _keepTouchBall(id:Int, touchX:Float, touchY:Float):Void {
    _balls.forEachAlive(function(b:Ball):Void {
      if(b.hold && b.getTouchID() == id) {
        // ホールド中
        b.touch(id, touchX, touchY);
      }
    });
  }

  /**
   * ボールの衝突処理
   **/
  function _cbBallVsBall(b1:Ball, b2:Ball):Void {
    var dx = b2.x - b1.x;
    var dy = b2.y - b1.y;
    var v = FlxVector.get(dx, dy);

    var v1 = FlxVector.get(b1.velocity.x, b1.velocity.y);
    var v2 = FlxVector.get(b2.velocity.x, b2.velocity.y);
    v1.rotateByRadians(v.radians);
    v2.rotateByRadians(v.radians+Math.PI);
    b1.velocity.set(v2.x, v2.y);
    b2.velocity.set(v1.x, v1.y);
  }
}
