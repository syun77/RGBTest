package jp_2dgames.game.field;

import jp_2dgames.lib.DirUtil;
import flixel.math.FlxPoint;
import flash.display.BlendMode;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.tile.FlxTilemap;
import jp_2dgames.lib.Array2D;
import jp_2dgames.lib.TextUtil;
import jp_2dgames.lib.TmxLoader;

/**
 * フィールド
 **/
class Field {

  // フィールドサイズ
  public static inline var GRID_X:Int = 7;
  public static inline var GRID_Y:Int = 9;

  public static inline var GRID_X_CENTER:Int = 3; // Xの中心
  public static inline var GRID_Y_TOP:Int    = 1; // Yの一番上
  public static inline var GRID_Y_BOTTOM:Int = 8; // Yの一番下

  // 次のブロックの位置
  public static inline var GRID_NEXT_X:Int = GRID_X_CENTER;
  public static inline var GRID_NEXT_Y:Int = 1;

  // オブジェクトレイヤー
  static inline var LAYER_NAME:String = "object";

  // 描画オフセット
  public static inline var OFFSET_X:Int = 20;
  public static inline var OFFSET_Y:Int = 128 - GRID_Y_TOP * TILE_HEIGHT;

  // タイルサイズ
  public static inline var TILE_WIDTH:Int  = 32;
  public static inline var TILE_HEIGHT:Int = 32;
  public static inline var GRID_SIZE:Int   = 32;

  static var _tmx:TmxLoader = null;
  static var _map:FlxTilemap = null;
  static var _layer:Array2D = null;
  static var _tmpLayer:Array2D = null;

  /**
   * マップデータ読み込み
   **/
  public static function loadLevel(level:Int):Void {

    var name = TextUtil.fillZero(level, 3);
    var file = 'assets/data/${name}.tmx';
    loadLevelFromFile(file);
  }

  /**
   * マップデータ読み込み (ファイルから読み込み)
   **/
  public static function loadLevelFromFile(file:String):Void {

    _tmx = new TmxLoader();
    _tmx.load(file);
    _layer = _tmx.getLayer(LAYER_NAME);
    _tmpLayer = new Array2D(_layer.width, _layer.height);
  }

  /**
   * マップデータ破棄
   **/
  public static function unload():Void {
    _tmx = null;
    _map = null;
  }

  /**
   * レイヤー情報の取得
   **/
  public static function getLayer():Array2D {
    return _layer;
  }

  /**
   * フィールドの幅
   **/
  public static function getWidth():Int {
    return _tmx.width * _tmx.tileWidth;
  }
  /**
   * フィールドの高さ
   **/
  public static function getHeight():Int {
    return _tmx.height * _tmx.tileHeight;
  }

  /**
   * グリッド座標をワールド座標に変換(X)
   **/
  public static function toWorldX(i:Float):Float {
    i = Math.max(i, 0);
    i = Math.min(i, GRID_X-1);
    return i * TILE_WIDTH + OFFSET_X;
  }

  /**
   * グリッド座標をワールド座標に変換(Y)
   **/
  public static function toWorldY(j:Float):Float {
    return j * TILE_HEIGHT + OFFSET_Y;
  }

  /**
   * グリッド座標をワールド座標(中心)に変換(X)
   **/
  public static function toWorldCenterX(i:Float):Float {
    return (i+0.5) * TILE_WIDTH + OFFSET_X;
  }

  /**
   * グリッド座標をワールド座標(中心)に変換(Y)
   **/
  public static function toWorldCenterY(j:Float):Float {
    return (j+0.5) * TILE_HEIGHT + OFFSET_Y;
  }

  /**
   * ワールド座標をグリッド座標に変換(X)
   **/
  public static function toGridX(i:Float):Int {
    return Math.floor((i-OFFSET_X) / TILE_WIDTH);
  }

  /**
   * ワールド座標をグリッド座標に変換(Y)
   **/
  public static function toGridY(j:Float):Int {
    return Math.floor((j-OFFSET_Y) / TILE_HEIGHT);
  }

  /**
   * 座標をグリッドに合わせる(X)
   **/
  public static function snapGridX(x:Float):Int {
    return Std.int((x-OFFSET_X) / GRID_SIZE) * GRID_SIZE + OFFSET_X;
  }

  /**
   * 座標をグリッドに合わせる(Y)
   **/
  public static function snapGridY(y:Float):Int {
    return Std.int((y-OFFSET_Y) / GRID_SIZE) * GRID_SIZE + OFFSET_Y;
  }
}

