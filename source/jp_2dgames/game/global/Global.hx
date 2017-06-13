package jp_2dgames.game.global;

import flixel.FlxG;
import flixel.util.FlxColor;

/**
 * グローバル変数
 **/
class Global {

  public static inline var TIME_LIMIT:Float = 60.0; // 1分間

  static var _level:Int  = 1; // レベル
  static var _score:Int  = 0; // スコア
  static var _time:Float = 0.0; // 残り時間

  static var _questionTbl:Array<Int>;

  public static function initGame():Void {
    _questionTbl = [
      FlxColor.GREEN,
      FlxColor.LIME,
      FlxColor.YELLOW,
      FlxColor.ORANGE,
      FlxColor.RED,
      FlxColor.PURPLE,
      FlxColor.BLUE,
      FlxColor.BROWN,
      FlxColor.PINK,
      FlxColor.MAGENTA,
      FlxColor.CYAN,
    ];

    FlxG.random.shuffleArray(_questionTbl, 3);
  }

  public static function getQuestionColor():Int {
    return _questionTbl[_level];
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
    if(_level > maxLevel) {
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
  static function get_maxLevel() { return _questionTbl.length; }
  static function get_time() { return _time; }
}
