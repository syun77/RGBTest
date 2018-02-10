package ;

import flash.display.BlendMode;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import PlayState.Team;
import flixel.FlxSprite;

/**
 * パーティクル
 **/
class Particle extends FlxSprite {

  public function new() {
    super();
    loadGraphic("assets/images/ring.png");
    blend = BlendMode.ADD;
    kill();
  }

  public function create(team:Team, X:Float, Y:Float):Void {
    x = X - width/2;
    y = Y - height/2;
    alpha = 1;
    scale.set(0, 0);
    if(team == Team.Red) {
      color = 0xFFFF8080;
    }
    else {
      color = 0xFF8080FF;
    }

    var time = 1;
    FlxTween.tween(scale, {x:10, y:10}, time, {ease:FlxEase.expoOut});
    FlxTween.tween(this, {alpha:0}, time, {ease:FlxEase.quadOut, onComplete:function(t:FlxTween):Void {
      kill();
    }});
  }
}

class ParticleMgr extends FlxTypedGroup<Particle> {
  public function new (MaxSize:Int) {
    super(MaxSize);
    for(i in 0...MaxSize) {
      var p = new Particle();
      this.add(p);
    }
  }
}

