package jp_2dgames.game.state;

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
  // ■フィールド
  var _state:State = State.Init;

  var _seq:SeqMgr;

  /**
   * 生成
   **/
  override public function create():Void {

    // 初期化
    Global.startLevel(1);

    // パーティクル生成
    Particle.createParent(this);
    ParticleBmpFont.createParent(this);
    StartStageUI.createInstance(this);

    var question = new FlxSprite(32, 32).makeGraphic(128*2, 32, FlxColor.BLUE);
    super.add(question);

    // シーケンス管理生成
    _seq = new SeqMgr();

    // UI ファイル読み込み
    _xml_id = "main";
    super.create();
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
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    switch(_state) {
      case State.Init:
        // ゲーム開始
        _updateInit();
        _state = State.Main;

      case State.Main:
        _updateMain();

      case State.DeadWait:
        // 死亡演出終了待ち

      case State.Gameover:
        // ゲームオーバー

      case State.LevelCompleted:
        // レベルクリア
        // TODO: タイトル画面に戻る
        FlxG.switchState(new EndingState());
    }

    #if debug
    _updateDebug();
    #end
  }

  /**
   * 更新・初期化
   **/
  function _updateInit():Void {
  }

  /**
   * 更新・メイン
   **/
  function _updateMain():Void {

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
