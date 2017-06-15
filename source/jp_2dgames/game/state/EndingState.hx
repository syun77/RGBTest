package jp_2dgames.game.state;
import jp_2dgames.game.global.Global;
import flixel.addons.transition.FlxTransitionableState;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.FlxG;

/**
 * エンディング画面
 **/
class EndingState extends FlxTransitionableState {

  static inline var FONT_SIZE:Int = 8 * 1;

  override public function create():Void {
    super.create();

    var txt = new FlxText(0, 32, FlxG.width, "RESULT", FONT_SIZE * 3);
    txt.setBorderStyle(FlxTextBorderStyle.OUTLINE, 2);
    txt.alignment = "center";
    this.add(txt);
    if(Global.level >= Global.maxLevel) {
      // 全ステージクリア時
      var msg = new FlxText(0, 80, FlxG.width, "completed all of the levels.", FONT_SIZE);
      // ボーナス加算
      var bonus:Int = Math.floor(Global.time) * 100;
      if(bonus > 0) {
        msg.text += '\n\nBonus: +${bonus}';
        Global.addScore(bonus);
      }
      msg.alignment = "center";
      this.add(msg);
    }

    // 結果スコア
    var txt2 = new FlxText(0, 128, FlxG.width, 'SCORE: ${Global.score}', FONT_SIZE * 2);
    txt2.alignment = FlxTextAlign.CENTER;
    this.add(txt2);

    // タイトルに戻るボタン
    var btn = new FlxButton(0, FlxG.height*0.8, "Back to TITLE", function() {
      FlxG.switchState(new TitleState());
    });
    btn.x = FlxG.width/2 - btn.width/2;
    this.add(btn);
  }

  override public function destroy():Void
  {
    super.destroy();
  }

  override public function update(elapsed:Float):Void
  {
    super.update(elapsed);
  }
}
