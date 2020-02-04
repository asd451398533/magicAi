/*
 * @author lsy
 * @date   2019-11-12
 **/
class AlbumUtil{

  static  String getFormatTime(String during) {
    if (during == null) {
      return "";
    } else {
      try {
        var parse = int.parse(during);
        String min;
        int minn;
        if (parse > 60 * 1000) {
          min = "00";
          minn = 0;
        } else {
          minn = (parse / (60 * 1000)).floor();
          min = "${minn}";
        }
        String second = "${((parse - minn * (60 * 1000)) / 1000).floor()}";

        if (min.length == 1) {
          min = "0$min";
        }
        if (second.length == 1) {
          second = "0$second";
        }
        if (min.length > 2) {
          min = "99";
        }
        return "$min:$second";
      } catch (e) {
        print(e);
        return "";
      }
    }
  }
}