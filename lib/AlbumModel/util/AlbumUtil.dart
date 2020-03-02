/*
 * @author lsy
 * @date   2019-11-12
 **/
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;
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

  static imglib.Image convertCameraImage(CameraImage image) {
    int width = image.width;
    int height = image.height;
    // imglib -> Image package from https://pub.dartlang.org/packages/image
    var img = imglib.Image(width, height); // Create Image buffer
    const int hexFF = 0xFF000000;
    final int uvyButtonStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel;
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex =
            uvPixelStride * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
        final int index = y * width + x;
        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        // Calculate pixel color
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        img.data[index] = hexFF | (b << 16) | (g << 8) | r;
      }
    }
    // Rotate 90 degrees to upright
    var img1 = imglib.copyRotate(img, 90);
    return img1;
  }
}