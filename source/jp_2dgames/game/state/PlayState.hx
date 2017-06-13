package jp_2dgames.game.state;

import jp_2dgames.lib.TextUtil;
import flixel.text.FlxText;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIRadioGroup;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIState;
import jp_2dgames.lib.MyShake;
import flixel.addons.transition.FlxTransitionableState;
import jp_2dgames.game.particle.StartStageUI;
import jp_2dgames.lib.Input;
import flash.system.System;
import jp_2dgames.game.particle.ParticleBmpFont;
import jp_2dgames.game.particle.Particle;
import flixel.FlxG;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.global.Global;

/**
 * 状態
 **/
private enum State {
  Init;
  Main;
  DeadWait;
  Gameover;
  LevelCompleted;
}

/**
 * メインゲーム画面
 **/
class PlayState extends FlxUIState {

  // ---------------------------------------
  // ■定数
  // レベルクリア時の待ち時間
  static inline var TIMER_LEVEL_COMPLETED:Float = 1.0;

  // ---------------------------------------
  // ■フィールド
  var _state:State = State.Init;
  var _seq:SeqMgr;
  var _radioRed:FlxUIRadioGroup;
  var _radioGreen:FlxUIRadioGroup;
  var _radioBlue:FlxUIRadioGroup;
  var _answerRedArray:Array<Int> = new Array<Int>();
  var _answerGreenArray:Array<Int> = new Array<Int>();
  var _answerBlueArray:Array<Int> = new Array<Int>();
  var _question:FlxColor;
  var _questionRed:Int;
  var _questionGreen:Int;
  var _questionBlue:Int;
  var _answerRed:Int = 0;
  var _answerGreen:Int = 0;
  var _answerBlue:Int = 0;

  var _countClicked:Int = 0; // クリック回数
  var _wait:Float = 0.0; // 停止タイマー

  var _sprQuestion:FlxSprite; // 問題スプライト
  var _sprAnswer:FlxSprite; // 答えスプライト
  var _sprResult:FlxSprite; // 結果背景
  var _txtScore:FlxText; // スコア
  var _txtTime:FlxText; // 残り時間テキスト
  var _txtResult:FlxText; // 結果テキスト
  var _txtBonus:FlxText; // 結果ボーナス

  /**
   * 生成
   **/
  override public function create():Void {

    // パーティクル生成
    Particle.createParent(this);
    ParticleBmpFont.createParent(this);
    StartStageUI.createInstance(this);

    // 問題作席
    _makeQuestion();

    // スプライト作成
    _sprQuestion = new FlxSprite(96, 24).makeGraphic(64*2, 32, _question);
    super.add(_sprQuestion);
    _sprAnswer = new FlxSprite(96, 168).makeGraphic(64*2, 32);
    _sprAnswer.color = FlxColor.BLACK;
    super.add(_sprAnswer);

    // テキスト生成
    _txtScore = new FlxText(4, 4, 0, "");
    super.add(_txtScore);
    _txtTime = new FlxText(4, 20, 0, "");
    super.add(_txtTime);

    // シーケンス管理生成
    _seq = new SeqMgr();

    // UI ファイル読み込み
    _xml_id = "main";
    super.create();

    // ラジオボタンを保存
    _ui.forEachOfType(IFlxUIWidget, function(widget:IFlxUIWidget) {
      switch(widget.name) {
        case "radio_red":
          _radioRed = cast widget;
        case "radio_green":
          _radioGreen = cast widget;
        case "radio_blue":
          _radioBlue = cast widget;
      }
    });

    _makeAnswer();

    // TODO:
    _updateRadio();

    // リザルト
    _sprResult = new FlxSprite(0, FlxG.height/2-40).makeGraphic(FlxG.width, 80, FlxColor.BLACK);
    _sprResult.alpha = 0.7;
    _sprResult.visible = false;
    //this.add(_sprResult);
    _txtResult = new FlxText(0, FlxG.height-32, FlxG.width, "", 16);
    _txtResult.alignment = FlxTextAlign.CENTER; // 中央揃え
    super.add(_txtResult);
    _txtBonus = new FlxText(0, FlxG.height-32, FlxG.width, "");
    super.add(_txtBonus);
  }

  /**
   * 問題の作成
   **/
  function _makeQuestion():Void {

    _question = new FlxColor(Global.getQuestionColor());
    _questionRed = _question.red;
    _questionGreen = _question.green;
    _questionBlue = _question.blue;
  }

  /**
   * 回答作成
   **/
  function _makeAnswer():Void {
    _answerRedArray = _makeAnswer2(_questionRed);
    _answerGreenArray = _makeAnswer2(_questionGreen);
    _answerBlueArray = _makeAnswer2(_questionBlue);
  }
  function _makeAnswer2(answer:Int):Array<Int> {
    var ret = new Array<Int>();
    var val:Int = FlxG.random.int(0, 0xFF);
    for(i in 0...3) {
      if(val == answer) {
        val += 32 + FlxG.random.int(0, 0x80);
      }
      if(val > 0xFF) {
        val -= 0xFF;
      }
      ret.push(val);
      val += 64 + FlxG.random.int(0, 0x40);
      if(val > 0xFF) {
        val -= 0xFF;
      }
    }
    ret[0] = answer;
    FlxG.random.shuffle(ret);
    return ret;
  }

  /**
   * ラジオボタンの項目を更新する
   **/
  function _updateRadio():Void {
    for(i in 0...3) {
      _radioRed.getRadios()[i].text = '${_answerRedArray[i]}';
      _radioGreen.getRadios()[i].text = '${_answerGreenArray[i]}';
      _radioBlue.getRadios()[i].text = '${_answerBlueArray[i]}';
    }
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {

    Particle.destroyParent();
    ParticleBmpFont.destroyParent();
    Input.destroyVirtualPad();
    StartStageUI.destroyInstance();

    super.destroy();
  }

  /**
   * UIWidgetのコールバック受け取り
   **/
  public override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
    var widget:IFlxUIWidget = cast sender;
    if(widget != null) {
      if(Std.is(widget, FlxUIRadioGroup)) {
        var radio:FlxUIRadioGroup = cast widget;
        switch(id) {
          case FlxUIRadioGroup.CLICK_EVENT:
            switch(radio.name) {
              case "radio_red":
                _answerRed = _answerRedArray[radio.selectedIndex];
                trace(_answerRed);
                _countClicked++;
              case "radio_green":
                _answerGreen = _answerGreenArray[radio.selectedIndex];
                trace(_answerGreen);
                _countClicked++;
              case "radio_blue":
                _answerBlue = _answerBlueArray[radio.selectedIndex];
                trace(_answerBlue);
                _countClicked++;
            }
            trace("選択した項目の番号は", radio.selectedIndex, "です", "name=", radio.name);
        }
      }
    }
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    // 残り時間更新
    _txtTime.text = 'TIME: ${Math.floor(Global.time)}';
    // スコア
    _txtScore.text = 'SCORE: ${Global.score}';

    switch(_state) {
      case State.Init:
        // ゲーム開始
        _updateInit();
        _state = State.Main;

      case State.Main:
        _updateMain(elapsed);

      case State.DeadWait:
        // 死亡演出終了待ち

      case State.Gameover:
        // ゲームオーバー

      case State.LevelCompleted:
        // レベルクリア
        _wait -= elapsed;
        if(_wait > 0) {
          return;
        }

        if(Global.nextLevel()) {
          // 全レベルクリア
          // TODO: タイトル画面に戻る
          FlxG.switchState(new EndingState());
        }
        else {
          // 次のレベルに進む
          FlxG.switchState((new PlayState()));
        }
    }

    #if debug
    _updateDebug();
    #end
  }

  /**
   * ボーナススコアを計算する
   **/
  function _calcBonus():Int {
    var val = 100 * (10 - _countClicked);
    if(val < 0) {
      return 0;
    }

    return val;
  }

  /**
   * リザルトテキストの設定
   **/
  function _setResult():Void {
    var val = _calcBonus();
    var base = 1000; // 基本スコア
    var score = base + val;
    _sprResult.visible = true;
    _txtResult.text = 'GREAT +${score}';
    Global.addScore(score);
    _txtResult.visible = true;
  }

  /**
   * 答えの色
   **/
  function _getAnswer():UInt {
    return (0xFF << 24) | (_answerRed << 16) | (_answerGreen << 8) | (_answerBlue);
  }

  /**
   * 更新・初期化
   **/
  function _updateInit():Void {
  }

  /**
   * 更新・メイン
   **/
  function _updateMain(elapsed:Float):Void {

    // 答えの色更新
    _sprAnswer.color = _getAnswer();

    var r1 = _questionRed;
    var g1 = _questionGreen;
    var b1 = _questionBlue;
    var r2 = _answerRed;
    var g2 = _answerGreen;
    var b2 = _answerBlue;

    if(r1 == r2 && g1 == g2 && b1 == b2) {
      // 正解
      _setResult();
      _state = State.LevelCompleted;
      _wait = TIMER_LEVEL_COMPLETED; // 3秒待つ
      return;
    }

    // 制限時間を減らす
    if(Global.decTime(elapsed) == false) {
      // 時間切れ
    }

    /*
    switch(_seq.proc()) {
      case SeqMgr.RET_DEAD:
        // ゲームオーバー
        _startGameover();
        Snd.stopMusic();

      case SeqMgr.RET_LEVEL_COMPLETED:
        // レベルクリア
        _state = State.LevelCompleted;
        Snd.stopMusic(1);
    }
    */
  }

  /**
   * ゲームオーバー開始
   **/
  function _startGameover():Void {
    _state = State.Gameover;
    // 画面を揺らす
    MyShake.high();
  }

  /**
   * デバッグ
   **/
  function _updateDebug():Void {

#if debug
#if desktop
    if(FlxG.keys.justPressed.ESCAPE) {
      // 強制終了
      System.exit(0);
    }
    if(FlxG.keys.justPressed.R) {
      // リスタート
      FlxG.resetState();
//      FlxG.switchState(StartStageUI PlayInitState());
    }

#end
#end
  }
}
