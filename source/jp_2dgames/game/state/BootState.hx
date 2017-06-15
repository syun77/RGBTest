package jp_2dgames.game.state;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import openfl.display.BitmapData;
import flixel.FlxG;
import jp_2dgames.lib.MyTransition;
import flixel.FlxState;

@:keep @:bitmap("assets/images/transitions/diamond.png")
class TransitionGraphicDiamond extends BitmapData {}

/**
 * 起動画面
 **/
class BootState extends FlxState {
  override public function create():Void {
    super.create();

#if flash
    // トランジション用オブジェクト生成
    MyTransition.create();
#else
    // トランジション用オブジェクト生成
    var size:Int = 32;
    MyTransition.create(size, size, TransitionGraphicDiamond);
#end
  }

  override public function destroy():Void {
    super.destroy();
  }

  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    #if flash
    FlxG.switchState(new TitleState());
    #else
//    FlxG.switchState(new PlayInitState());
    FlxG.switchState(new TitleState());
//    FlxG.switchState(new EndingState());
//    FlxG.switchState(new ResultState());
//    FlxG.switchState(new MakeCharacterState());
    #end
  }
}
