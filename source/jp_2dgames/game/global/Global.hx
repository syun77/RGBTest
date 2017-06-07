package jp_2dgames.game.global;

/**
 * グローバル変数
 **/
class Global {

  public static inline var MAX_LEVEL:Int = 4;
  public static inline var TIME_LIMIT:Float = 60.0; // 1分間

  static var _level:Int  = 1; // レベル
  static var _score:Int  = 0; // スコア
  static var _time:Float = 0.0; // 残り時間

  public static function initGame():Void {
    // tODO: 未実装
  }

  public static function startLevel(lv:Int):Void {
    _level = lv;
    _score = 0;
    _time  = TIME_LIMIT;
  }

  /**
   * 制限時間を減らす
   **/
  public static function decTime(d:Float):Bool {
    _time -= d;
    if(_time < 0) {
      // 時間切れ
      _time = 0;
      return false;
    }

    return true;
  }

  /**
   * 次のレベルに進む
   **/
  public static function nextLevel():Bool {
    _level++;
    if(_level > MAX_LEVEL) {
      // 全レベルクリア
      return true;
    }
    return false;
  }

  /**
   * スコア加算
   **/
  public static function addScore(v:Int):Void {
    _score += v;
  }

  public static var level(get, never):Int;
  public static var score(get, never):Int;
  public static var maxLevel(get, never):Int;
  public static var time(get, never):Float;
  static function get_level() { return _level; }
  static function get_score() { return _score; }
  static function get_maxLevel() { return MAX_LEVEL; }
  static function get_time() { return _time; }
}
