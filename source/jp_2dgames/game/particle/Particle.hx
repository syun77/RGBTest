package jp_2dgames.game.particle;

import flixel.effects.FlxFlicker;
import flash.display.BlendMode;
import flixel.util.FlxColor;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import jp_2dgames.game.token.Token;

/**
 * パーティクルの種類
 **/
enum ParticleType {
  Ball;   // 球体
  Ring;   // ドーナッツ状の円
  Blade;  // 長細い
  Rect;   // 矩形
  Circle; // 円
  CircleReverse; // 円の逆再生
  Stone;  // ブロック破片
}

/**
 * パーティクル
 **/
class Particle extends Token {

  public static var parent:FlxTypedGroup<Particle> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Particle>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }

  /**
   * 追加
   **/
  public static function add(Type:ParticleType, X:Float, Y:Float, deg:Float=0, speed:Float=0):Particle {
    var particle:Particle = parent.recycle(Particle);
    particle.init(Type, X, Y, deg, speed);
    return particle;
  }

  // ===========================================
  // ■プロパティ
  public var age(default, default):Float; // 死亡までの時間

  // ===========================================
  // ■フィールド
  var _type:ParticleType;
  var _lifespan:Float;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_PARTICLE, true);
    // アニメーション登録
    _registerAnimations();
  }

  /**
   * 初期化
   **/
  public function init(Type:ParticleType, X:Float, Y:Float, deg:Float, speed:Float):Void {
    x = X - width/2;
    y = Y - height/2;
    setVelocity(deg, speed);
    _type = Type;
    animation.play('${_type}');
    _lifespan = 0;
    age = 1;

    // パラメータ初期化
    scale.set(1, 1);
    alpha = 1;
    color = FlxColor.WHITE;
    blend = BlendMode.ADD;
    drag.set();
    angle = 0;
    acceleration.set();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {

    _lifespan += elapsed;
    if(_lifespan >= age) {
      // 消滅
      kill();
      return;
    }

    switch(_type) {
      case ParticleType.Ball:  // 球体
        alpha -= elapsed/age;
        scale.x *= 0.95;
        scale.y *= 0.95;
        velocity.x *= 0.97;
        velocity.y *= 0.97;

      case ParticleType.Ring:  // ドーナッツ状の円
        var sc = elapsed/age * 4;
        scale.add(sc, sc);
        alpha -= elapsed;

      case ParticleType.Blade: // 長細い
        alpha -= elapsed/age;

      case ParticleType.Rect:  // 矩形
        var sc = elapsed;
        scale.add(sc, sc);
        alpha -= elapsed;

      case ParticleType.Circle: // 円
        var sc = elapsed * 1.5;
        scale.add(sc, sc);
        alpha -= elapsed/age * 1.5;

      case ParticleType.CircleReverse: // 円の逆再生
        scale.scale(0.93);
        alpha -= elapsed/age * 1.5;

      case ParticleType.Stone: // 固いブロックの破片
        if(_lifespan/age > 0.7) {
          if(FlxFlicker.isFlickering(this) == false) {
            // 点滅開始
            FlxFlicker.flicker(this, _lifespan);
          }
        }
    }

    super.update(elapsed);
  }

  /**
   * アニメーションの登録
   **/
  function _registerAnimations():Void {
    animation.add('${ParticleType.Ball}',   [0]);
    animation.add('${ParticleType.Ring}',   [1]);
    animation.add('${ParticleType.Blade}',  [2]);
    animation.add('${ParticleType.Rect}' ,  [3]);
    animation.add('${ParticleType.Circle}', [4]);
    animation.add('${ParticleType.Stone}',  [5]);
    animation.add('${ParticleType.CircleReverse}', [4]);
  }

  // ===========================================
  // ■アクセサ
}
