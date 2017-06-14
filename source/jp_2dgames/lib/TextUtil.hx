package jp_2dgames.lib;

/**
 * テキストユーティリティ
 * @author syun
 */
class TextUtil {

  public function new() {
  }

  /**
     * ０埋めした数値文字列を返す
     * @param	n 元の数値
     * @param	digit ゼロ埋めする桁数
     * @return  ゼロ埋めした文字列
     */

  public static function fillZero(n:Int, digit:Int):String {
    var str:String = "" + n;
    return StringTools.lpad(str, "0", digit);
  }
  /**
     * スペース埋めした数値文字列を返す
     * @param	n
     * @param	digit
     * @return
     */

  public static function fillSpace(n:Int, digit:Int):String {
    var str:String = "" + n;
    return StringTools.lpad(str, " ", digit);
  }

  /**
   * 秒を「HH:MM:SS」形式の文字列に変換して返す
   **/
  public static function secToHHMMSS(sec:Int):String {
    var hour   = Std.int(sec / 60 / 60);
    var minute = Std.int(sec / 60);
    var second = sec % 60;

    return fillZero(hour, 2) + ":" + fillZero(minute, 2) + ":" + fillZero(second, 2);
  }

  /**
   * 16進数に変換した文字を返す
   * @param dec 変換する数値
   * @param bUpper 大文字にするかどうか
   * @param digit 0埋めの桁数
   * @return 変換後の文字列
   **/
  public static function toHex(dec:Int, bUpper:Bool=true, digit:Int=0):String {
    var str = "";
    var v = dec;
    while(v > 0) {
      var upper = (v >> 4) << 4;
      var lower = v - upper;
      if(lower < 10) {
        // 9以下はそのまま
        str = '${lower}' + str;
      }
      else {
        var tbl = ['A', 'B', 'C', 'D', 'E', 'F'];
        if(bUpper) {
          // 大文字を使う
          str = tbl[lower - 10] + str;
          trace("upper:", upper, " lower:", lower, " str:", str);
        }
        else {
          // 小文字を使う
          str = tbl[lower - 10].toLowerCase() + str;
        }
      }
      v = (upper >> 4);
    }

    if(digit > 0) {
      str = StringTools.lpad(str, '0', digit);
    }
    return str;
  }

}

