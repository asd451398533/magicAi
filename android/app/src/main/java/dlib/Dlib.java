package dlib;

import android.graphics.Bitmap;
import android.graphics.Rect;

import java.util.ArrayList;
import java.util.List;

/**
 * @author lsy
 * @date 2019-12-23
 */
public class Dlib {

    static {
        System.loadLibrary("native-lib");
    }

    public native int[] detectImg(int[] pixels, int height, int width);

    public List<Rect> face_detection(Bitmap origin_image, float scareSize) {
        float scale = scareSize / Math.max(origin_image.getHeight(), origin_image.getWidth());
        int width = (int) (origin_image.getWidth() * scale);
        int height = (int) (origin_image.getHeight() * scale);
        Bitmap resize_image = Bitmap.createScaledBitmap(origin_image, width, height, false);
        int[] pixels = new int[width * height];
        resize_image.getPixels(pixels, 0, width, 0, 0, width, height);
        int[] rect = detectImg(pixels, height, width);
        List<Rect> list = new ArrayList<>();
        for (int i = 0; i < rect.length; i += 4) {
            list.add(new Rect((int) (rect[i] / scale)
                    , (int) (rect[i + 1] / scale)
                    , (int) (rect[i] / scale) + (int) (rect[i + 2] / scale)
                    , (int) (rect[i + 1] / scale) + (int) (rect[i + 3] / scale)));
        }
        return list;
    }
}
