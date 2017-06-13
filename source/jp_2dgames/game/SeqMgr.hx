package jp_2dgames.game;

import jp_2dgames.lib.Snd;
import jp_2dgames.game.particle.StartStageUI;
import flixel.math.FlxMath;
import jp_2dgames.lib.Input;
import flixel.FlxG;
import jp_2dgames.game.dat.MyDB;

/**
 * 状態
 **/
private enum State {

  None;              // 無効

  Init;              // 初期化

  Main;              // メイン

  GameOver;          // ゲームオーバー

  LevelCompleted;    // ステージクリア

  End;               // おしまい

}

/**
 * シーケンス管理
 **/
class SeqMgr {

  public static var RET_NONE:Int    = 0;
  public static var RET_DEAD:Int    = 3; // プレイヤー死亡
  public static var RET_LEVEL_COMPLETED:Int  = 5; // レベルクリア

  // 状態
  var _state:State;
  var _statePrev:State;

  /**
   * コンストラクタ
   **/
  public function new() {
    _state = State.Init;
    _statePrev = _state;

    // デバッグ用
    FlxG.watch.add(this, "_state");
    FlxG.watch.add(this, "_statePrev");
  }

  /**
   * 状態遷移
   **/
  function _change(next:State):Void {
    trace('${_state} -> ${next}');
    _statePrev = _state;
    _state = next;
  }

  function _procInit():State {

    // 開始演出
    //StartStageUI.start();

    return State.Main;
  }

  function _procMain():State {
    return State.None;
  }

  function _procGameOver():State {
    return State.None;
  }

  function _procEnd():State {
    return State.None;
  }

  /**
   * 更新
   **/
  public function proc():Int {

    var ret = RET_NONE;
    var tbl = [
      State.Init              => _procInit,       // 初期化

      State.Main              => _procMain,

      State.GameOver          => _procGameOver,          // ゲームオーバー

      State.End               => _procEnd,               // おしまい

    ];

    var next = tbl[_state]();
    if(next != State.None) {
      // 状態遷移
      _change(next);
    }

    if(_state == State.GameOver) {
      // プレイヤー死亡
      return RET_DEAD;
    }

    return RET_NONE;
  }
}
