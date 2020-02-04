/*
 * @author lsy
 * @date   2020-01-03
 **/
class WantCache {
  Map<int, List<List<Map<String, String>>>> cacheMap = new Map();

  WantCache() {
    Map<String, String> map = new Map()
      ..putIfAbsent("eye_big", () => "眼睛变大")
      ..putIfAbsent("eye_open", () => "开眼角")
      ..putIfAbsent("chin", () => "丰下巴")
      ..putIfAbsent("nose", () => "鼻翼缩小")
      ..putIfAbsent("face", () => "瘦脸")
      ..putIfAbsent("lip", () => "嘴唇变薄")
      ..putIfAbsent("tooth", () => "牙齿正畸")
      ..putIfAbsent("wrinkles", () => "淡化法令纹")
      ..putIfAbsent("bound", () => "颧骨降低")
      ..putIfAbsent("temples", () => "丰太阳穴")
      ..putIfAbsent("black", () => "祛黑眼圈")
      ..putIfAbsent("eye_bag", () => "祛眼袋");

    cacheMap.putIfAbsent(1, () {
      return List()
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_big", () => "眼睛变大")
            ..putIfAbsent("face", () => "瘦脸")
            ..putIfAbsent("lip", () => "嘴唇变薄")))
        //2
        ..add(List()
          ..add(Map()
            ..putIfAbsent("chin", () => "丰下巴")
            ..putIfAbsent("eye_open", () => "开眼角")
            ..putIfAbsent("nose", () => "鼻翼缩小")))
        //3
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_big", () => "眼睛变大")
            ..putIfAbsent("bound", () => "颧骨降低")
            ..putIfAbsent("lip", () => "嘴唇变薄")))
        //4
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_open", () => "开眼角")
            ..putIfAbsent("nose", () => "鼻翼缩小")
            ..putIfAbsent("lip", () => "嘴唇变薄")))
        //5
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_big", () => "眼睛变大")
            ..putIfAbsent("bound", () => "颧骨降低")
            ..putIfAbsent("wrinkles", () => "淡化法令纹")))
        //6
        ..add(List()
          ..add(Map()
            ..putIfAbsent("lip", () => "嘴唇变薄")
            ..putIfAbsent("chin", () => "丰下巴")
            ..putIfAbsent("eye_open", () => "开眼角")))
        //7
        ..add(List()
          ..add(Map()
            ..putIfAbsent("lip", () => "嘴唇变薄")
            ..putIfAbsent("eye_open", () => "开眼角")
            ..putIfAbsent("nose", () => "鼻翼缩小")));
    });

    cacheMap.putIfAbsent(2, () {
      return List()
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_big", () => "眼睛变大")
            ..putIfAbsent("face", () => "瘦脸")
            ..putIfAbsent("lip", () => "丰唇")))
        //2
        ..add(List()
          ..add(Map()
            ..putIfAbsent("black", () => "祛黑眼圈")
            ..putIfAbsent("tooth", () => "牙齿正畸")
            ..putIfAbsent("lip", () => "丰唇")))
        //3
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_big", () => "眼睛变大")
            ..putIfAbsent("face", () => "瘦脸")
            ..putIfAbsent("lip", () => "丰唇")))
        //4
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_big", () => "眼睛变大")
            ..putIfAbsent("tooth", () => "牙齿正畸")
            ..putIfAbsent("chin", () => "丰下巴")))
        //5
        ..add(List()
          ..add(Map()
            ..putIfAbsent("face", () => "瘦脸")
            ..putIfAbsent("eye_bag", () => "祛眼袋")
            ..putIfAbsent("lip", () => "丰唇")))
        //6
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_big", () => "眼睛变大")
            ..putIfAbsent("bound", () => "颧骨降低")
            ..putIfAbsent("wrinkles", () => "淡化法令纹")))
        //7
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_big", () => "眼睛变大")
            ..putIfAbsent("face", () => "瘦脸")
            ..putIfAbsent("lip", () => "丰唇")));
    });

    cacheMap.putIfAbsent(3, () {
      return List()
        ..add(List()
          ..add(Map()
            ..putIfAbsent("nose", () => "鼻翼缩小")
            ..putIfAbsent("eye_open", () => "开眼角")
            ..putIfAbsent("lip", () => "嘴唇变薄")
          )
        )
      //2
        ..add(List()
          ..add(Map()
            ..putIfAbsent("bound", () => "颧骨降低")
            ..putIfAbsent("nose", () => "鼻翼缩小")
            ..putIfAbsent("lip", () => "嘴唇变薄")
          ))
      //3
        ..add(List()
          ..add(Map()
            ..putIfAbsent("nose", () => "鼻翼缩小")
            ..putIfAbsent("bound", () => "颧骨降低")
            ..putIfAbsent("lip", () => "嘴唇变薄")
          ))
      //4
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_big", () => "眼睛变大")
            ..putIfAbsent("bound", () => "颧骨降低")
            ..putIfAbsent("wrinkles", () => "淡化法令纹")
          ))
      //5
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_big", () => "眼睛变大")
            ..putIfAbsent("eye_open", () => "开眼角")
            ..putIfAbsent("nose", () => "鼻翼缩小")

          ))
      //6
        ..add(List()
          ..add(Map()
            ..putIfAbsent("wrinkles", () => "淡化法令纹")
            ..putIfAbsent("bound", () => "颧骨降低")
            ..putIfAbsent("lip", () => "嘴唇变薄")
          ))
      //7
        ..add(List()
          ..add(Map()
            ..putIfAbsent("chin", () => "丰下巴")
            ..putIfAbsent("eye_open", () => "开眼角")
            ..putIfAbsent("nose", () => "鼻翼缩小")
          ));
    });

    cacheMap.putIfAbsent(4, () {
      return List()
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_big", () => "眼睛变大")
            ..putIfAbsent("bound", () => "颧骨降低")
            ..putIfAbsent("nose", () => "鼻翼缩小")
          )
        )
      //2
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_big", () => "眼睛变大")
            ..putIfAbsent("bound", () => "颧骨降低")
            ..putIfAbsent("lip", () => "嘴唇变薄")
          ))
      //3
        ..add(List()
          ..add(Map()
            ..putIfAbsent("wrinkles", () => "淡化法令纹")
            ..putIfAbsent("bound", () => "颧骨降低")
            ..putIfAbsent("chin", () => "丰下巴")
          ))
      //4
        ..add(List()
          ..add(Map()
            ..putIfAbsent("tooth", () => "牙齿正畸")
            ..putIfAbsent("bound", () => "颧骨降低")
            ..putIfAbsent("temples", () => "丰太阳穴")
          ))
      //5
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_big", () => "眼睛变大")
            ..putIfAbsent("bound", () => "颧骨降低")
            ..putIfAbsent("wrinkles", () => "淡化法令纹")
          ))
      //6
        ..add(List()
          ..add(Map()
            ..putIfAbsent("bound", () => "颧骨降低")
            ..putIfAbsent("lip", () => "嘴唇变薄")
            ..putIfAbsent("nose", () => "鼻翼缩小")
          ))
      //7
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_big", () => "眼睛变大")
            ..putIfAbsent("bound", () => "颧骨降低")
            ..putIfAbsent("wrinkles", () => "淡化法令纹")
          ));
    });


    cacheMap.putIfAbsent(5, () {
      return List()
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_open", () => "开眼角")
            ..putIfAbsent("nose", () => "鼻翼缩小")
            ..putIfAbsent("wrinkles", () => "淡化法令纹")
          )
        )
      //2
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_big", () => "眼睛变大")
            ..putIfAbsent("temples", () => "丰太阳穴")
            ..putIfAbsent("tooth", () => "牙齿正畸")
          ))
      //3
        ..add(List()
          ..add(Map()
            ..putIfAbsent("lip", () => "嘴唇变薄")
            ..putIfAbsent("bound", () => "颧骨降低")
            ..putIfAbsent("wrinkles", () => "淡化法令纹")
          ))
      //4
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_big", () => "眼睛变大")
            ..putIfAbsent("nose", () => "鼻翼缩小")
            ..putIfAbsent("bound", () => "颧骨降低")
          ))
      //5
        ..add(List()
          ..add(Map()
            ..putIfAbsent("lip", () => "嘴唇变薄")
            ..putIfAbsent("bound", () => "颧骨降低")
            ..putIfAbsent("eye_big", () => "眼睛变大")
          ))
      //6
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_big", () => "眼睛变大")
            ..putIfAbsent("lip", () => "嘴唇变薄")
            ..putIfAbsent("wrinkles", () => "淡化法令纹")
          ))
      //7
        ..add(List()
          ..add(Map()
            ..putIfAbsent("chin", () => "丰下巴")
            ..putIfAbsent("bound", () => "颧骨降低")
            ..putIfAbsent("wrinkles", () => "淡化法令纹")
          ));
    });


    cacheMap.putIfAbsent(6, () {
      return List()
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_big", () => "眼睛变大")
            ..putIfAbsent("temples", () => "丰太阳穴")
            ..putIfAbsent("tooth", () => "牙齿正畸")
          )
        )
      //2
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_big", () => "眼睛变大")
            ..putIfAbsent("bound", () => "颧骨降低")
            ..putIfAbsent("wrinkles", () => "淡化法令纹")
          ))
      //3
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_big", () => "眼睛变大")
            ..putIfAbsent("tooth", () => "牙齿正畸")
            ..putIfAbsent("temples", () => "丰太阳穴")
          ))
      //4
        ..add(List()
          ..add(Map()
            ..putIfAbsent("lip", () => "嘴唇变薄")
            ..putIfAbsent("bound", () => "颧骨降低")
            ..putIfAbsent("eye_big", () => "眼睛变大")
          ))
      //5
        ..add(List()
          ..add(Map()
            ..putIfAbsent("lip", () => "嘴唇变薄")
            ..putIfAbsent("wrinkles", () => "淡化法令纹")
            ..putIfAbsent("eye_big", () => "眼睛变大")
          ))
      //6
        ..add(List()
          ..add(Map()
            ..putIfAbsent("lip", () => "嘴唇变薄")
            ..putIfAbsent("wrinkles", () => "淡化法令纹")
            ..putIfAbsent("bound", () => "颧骨降低")
          ))
      //7
        ..add(List()
          ..add(Map()
            ..putIfAbsent("wrinkles", () => "淡化法令纹")
            ..putIfAbsent("eye_big", () => "眼睛变大")
            ..putIfAbsent("bound", () => "颧骨降低")
          ));
    });


    cacheMap.putIfAbsent(7, () {
      return List()
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_open", () => "开眼角")
            ..putIfAbsent("nose", () => "鼻翼缩小")
            ..putIfAbsent("brow", () => "植眉")
          )
        )
      //2
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_big", () => "眼睛变大")
            ..putIfAbsent("wrinkles", () => "淡化法令纹")
            ..putIfAbsent("bound", () => "颧骨降低")
          ))
      //3
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_big", () => "眼睛变大")
            ..putIfAbsent("nose", () => "鼻翼缩小")
            ..putIfAbsent("lip", () => "嘴唇变薄")
          ))
      //4
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_big", () => "眼睛变大")
            ..putIfAbsent("wrinkles", () => "淡化法令纹")
          ))
      //5
        ..add(List()
          ..add(Map()
            ..putIfAbsent("bound", () => "颧骨降低")
            ..putIfAbsent("nose", () => "鼻翼缩小")
            ..putIfAbsent("lip", () => "嘴唇变薄")
          ))
      //6
        ..add(List()
          ..add(Map()
            ..putIfAbsent("temples", () => "丰太阳穴")
            ..putIfAbsent("wrinkles", () => "淡化法令纹")
            ..putIfAbsent("tooth", () => "牙齿正畸")
          ))
      //7
        ..add(List()
          ..add(Map()
            ..putIfAbsent("bound", () => "颧骨降低")
            ..putIfAbsent("chin", () => "丰下巴")
            ..putIfAbsent("wrinkles", () => "淡化法令纹")
          ));
    });


    cacheMap.putIfAbsent(8, () {
      return List()
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_open", () => "开眼角")
            ..putIfAbsent("nose", () => "鼻翼缩小")
            ..putIfAbsent("wrinkles", () => "淡化法令纹")
          )
        )
      //2
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_big", () => "眼睛变大")
            ..putIfAbsent("lip", () => "嘴唇变薄")
            ..putIfAbsent("head", () => "丰额头")
          ))
      //3
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_big", () => "眼睛变大")
            ..putIfAbsent("nose", () => "鼻翼缩小")
            ..putIfAbsent("temples", () => "丰太阳穴")
          ))
      //4
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_big", () => "眼睛变大")
            ..putIfAbsent("temples", () => "丰太阳穴")
            ..putIfAbsent("tooth", () => "牙齿正畸")
          ))
      //5
        ..add(List()
          ..add(Map()
            ..putIfAbsent("tooth", () => "牙齿正畸")
            ..putIfAbsent("brow", () => "植眉")
            ..putIfAbsent("eye_open", () => "开眼角")
          ))
      //6
        ..add(List()
          ..add(Map()
            ..putIfAbsent("nose", () => "鼻翼缩小")
            ..putIfAbsent("chin", () => "丰下巴")
            ..putIfAbsent("eye_open", () => "开眼角")
          ))
      //7
        ..add(List()
          ..add(Map()
            ..putIfAbsent("eye_big", () => "眼睛变大")
            ..putIfAbsent("lip", () => "嘴唇变薄")
            ..putIfAbsent("wrinkles", () => "淡化法令纹")
          ));
    });


//    cacheMap.putIfAbsent(3, () {
//      return List()
//        ..add(List()
//          ..add(Map()
//            ..putIfAbsent("eye_big", () => "眼睛变大")
//            ..putIfAbsent("eye_open", () => "开眼角")
//            ..putIfAbsent("chin", () => "丰下巴")
//            ..putIfAbsent("nose", () => "鼻翼缩小")
//            ..putIfAbsent("face", () => "瘦脸")
//            ..putIfAbsent("lip", () => "嘴唇变薄")
//            ..putIfAbsent("tooth", () => "牙齿正畸")
//            ..putIfAbsent("wrinkles", () => "淡化法令纹")
//            ..putIfAbsent("bound", () => "颧骨降低")
//            ..putIfAbsent("temples", () => "丰太阳穴")
//            ..putIfAbsent("black", () => "祛黑眼圈")
//            ..putIfAbsent("eye_bag", () => "祛眼袋")
//          )
//        )
//      //2
//        ..add(List()
//          ..add(Map()
//            ..putIfAbsent("eye_big", () => "眼睛变大")
//            ..putIfAbsent("eye_open", () => "开眼角")
//            ..putIfAbsent("chin", () => "丰下巴")
//            ..putIfAbsent("nose", () => "鼻翼缩小")
//            ..putIfAbsent("face", () => "瘦脸")
//            ..putIfAbsent("lip", () => "嘴唇变薄")
//            ..putIfAbsent("tooth", () => "牙齿正畸")
//            ..putIfAbsent("wrinkles", () => "淡化法令纹")
//            ..putIfAbsent("bound", () => "颧骨降低")
//            ..putIfAbsent("temples", () => "丰太阳穴")
//            ..putIfAbsent("black", () => "祛黑眼圈")
//            ..putIfAbsent("eye_bag", () => "祛眼袋")
//          ))
//      //3
//        ..add(List()
//          ..add(Map()
//            ..putIfAbsent("eye_big", () => "眼睛变大")
//            ..putIfAbsent("eye_open", () => "开眼角")
//            ..putIfAbsent("chin", () => "丰下巴")
//            ..putIfAbsent("nose", () => "鼻翼缩小")
//            ..putIfAbsent("face", () => "瘦脸")
//            ..putIfAbsent("lip", () => "嘴唇变薄")
//            ..putIfAbsent("tooth", () => "牙齿正畸")
//            ..putIfAbsent("wrinkles", () => "淡化法令纹")
//            ..putIfAbsent("bound", () => "颧骨降低")
//            ..putIfAbsent("temples", () => "丰太阳穴")
//            ..putIfAbsent("black", () => "祛黑眼圈")
//            ..putIfAbsent("eye_bag", () => "祛眼袋")
//          ))
//      //4
//        ..add(List()
//          ..add(Map()
//            ..putIfAbsent("eye_big", () => "眼睛变大")
//            ..putIfAbsent("eye_open", () => "开眼角")
//            ..putIfAbsent("chin", () => "丰下巴")
//            ..putIfAbsent("nose", () => "鼻翼缩小")
//            ..putIfAbsent("face", () => "瘦脸")
//            ..putIfAbsent("lip", () => "嘴唇变薄")
//            ..putIfAbsent("tooth", () => "牙齿正畸")
//            ..putIfAbsent("wrinkles", () => "淡化法令纹")
//            ..putIfAbsent("bound", () => "颧骨降低")
//            ..putIfAbsent("temples", () => "丰太阳穴")
//            ..putIfAbsent("black", () => "祛黑眼圈")
//            ..putIfAbsent("eye_bag", () => "祛眼袋")
//          ))
//      //5
//        ..add(List()
//          ..add(Map()
//            ..putIfAbsent("eye_big", () => "眼睛变大")
//            ..putIfAbsent("eye_open", () => "开眼角")
//            ..putIfAbsent("chin", () => "丰下巴")
//            ..putIfAbsent("nose", () => "鼻翼缩小")
//            ..putIfAbsent("face", () => "瘦脸")
//            ..putIfAbsent("lip", () => "嘴唇变薄")
//            ..putIfAbsent("tooth", () => "牙齿正畸")
//            ..putIfAbsent("wrinkles", () => "淡化法令纹")
//            ..putIfAbsent("bound", () => "颧骨降低")
//            ..putIfAbsent("temples", () => "丰太阳穴")
//            ..putIfAbsent("black", () => "祛黑眼圈")
//            ..putIfAbsent("eye_bag", () => "祛眼袋")
//          ))
//      //6
//        ..add(List()
//          ..add(Map()
//            ..putIfAbsent("eye_big", () => "眼睛变大")
//            ..putIfAbsent("eye_open", () => "开眼角")
//            ..putIfAbsent("chin", () => "丰下巴")
//            ..putIfAbsent("nose", () => "鼻翼缩小")
//            ..putIfAbsent("face", () => "瘦脸")
//            ..putIfAbsent("lip", () => "嘴唇变薄")
//            ..putIfAbsent("tooth", () => "牙齿正畸")
//            ..putIfAbsent("wrinkles", () => "淡化法令纹")
//            ..putIfAbsent("bound", () => "颧骨降低")
//            ..putIfAbsent("temples", () => "丰太阳穴")
//            ..putIfAbsent("black", () => "祛黑眼圈")
//            ..putIfAbsent("eye_bag", () => "祛眼袋")
//          ))
//      //7
//        ..add(List()
//          ..add(Map()
//            ..putIfAbsent("eye_big", () => "眼睛变大")
//            ..putIfAbsent("eye_open", () => "开眼角")
//            ..putIfAbsent("chin", () => "丰下巴")
//            ..putIfAbsent("nose", () => "鼻翼缩小")
//            ..putIfAbsent("face", () => "瘦脸")
//            ..putIfAbsent("lip", () => "嘴唇变薄")
//            ..putIfAbsent("tooth", () => "牙齿正畸")
//            ..putIfAbsent("wrinkles", () => "淡化法令纹")
//            ..putIfAbsent("bound", () => "颧骨降低")
//            ..putIfAbsent("temples", () => "丰太阳穴")
//            ..putIfAbsent("black", () => "祛黑眼圈")
//            ..putIfAbsent("eye_bag", () => "祛眼袋")
//          ));
//    });
  }

  Map<int, List<List<Map<String, String>>>> getCacheMap() {
   return cacheMap;
  }
}
