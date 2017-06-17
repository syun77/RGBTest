package jp_2dgames.game.state;
import jp_2dgames.lib.Snd;
import flixel.addons.transition.FlxTransitionableState;
import jp_2dgames.game.global.Global;
import flixel.FlxG;

/**
 * ゲーム開始画面
 **/
class PlayInitState extends FlxTransitionableState {
  override public function create():Void {
    super.create();

    Global.initGame();
    Global.startLevel(0);
    Snd.playMusic("001");
  }

  override public function destroy():Void {
    super.destroy();
  }

  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    FlxG.switchState(new PlayState());
  }
}
