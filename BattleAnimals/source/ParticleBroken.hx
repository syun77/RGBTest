package ;

import flash.display.BlendMode;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import PlayState.Team;
import flixel.FlxSprite;

/**
 * パーティクル
 **/
class ParticleBroken extends FlxSprite {

  public function new() {
    super();
    makeGraphic(16, 16, FlxColor.WHITE);
    blend = BlendMode.ADD;
    kill();
  }

  public function create(team:Team, X:Float, Y:Float):Void {
    x = X - width/2;
    y = Y - height/2;
    alpha = 1;

    if(team == Team.Red) {
      color = 0xFFFF8080;
    }
    else {
      color = 0xFF8080FF;
    }
    var rad   = FlxG.random.float(0, Math.PI*2);
    var speed = FlxG.random.float(150, 600);
    velocity.x = speed * Math.cos(rad);
    velocity.y = speed * Math.sin(rad);
    acceleration.y = 100;

    var time = FlxG.random.float(0.5, 2);
    FlxTween.tween(this, {alpha:0}, time, {ease:FlxEase.quadOut, onComplete:function(t:FlxTween) {
      kill();
    }});
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    velocity.x *= 0.97;
    velocity.y *= 0.97;
  }
}

class ParticleBrokenMgr extends FlxTypedGroup<ParticleBroken> {
  public function new (MaxSize:Int) {
    super(MaxSize);
    for(i in 0...MaxSize) {
      var p = new ParticleBroken();
      this.add(p);
    }
  }
}

