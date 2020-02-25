/*
 * @author lsy
 * @date   2020-02-19
 **/
import 'package:flutter/cupertino.dart';
import 'package:gengmei_app_face/HomeModel/repo/HomeRepo.dart';
import 'package:gengmei_app_face/commonModel/GMBase.dart';
import 'package:gengmei_app_face/commonModel/toast/toast.dart';
import 'package:gengmei_app_face/main.mark.dart';

class DetectFaceModel extends BaseModel {
  LiveData<String> messageLive = LiveData();

  @override
  void dispose() {
    messageLive.dispost();
  }

  void init(BuildContext context, String filePath) {
    RouterCenterImpl().findAiRouter().uploadImg(filePath).listen((value) {
      if (value.fileUrl != null) {
        String finalUrl = value.fileUrl;
        if (finalUrl.contains("half")) {
          finalUrl = finalUrl.replaceAll("half", "w");
        }
        HomeRepo.getInstance().getImageAi(finalUrl).listen((value) {
          if (value.data.faceshape == null ||
              value.data.eyeShapeRight == null) {
            messageLive.notifyView("ai没有识别出结果");
          } else {
            Navigator.pop(context, [
              value.data.faceshape[0].type,
              value.data.eyeShapeRight[0].type
            ]);
          }
        }).onError((error) {
          messageLive.notifyView(error.toString());
          Toast.show(context, error.toString());
        });
      } else {
        messageLive.notifyView("上传图片失败");
        Toast.show(context, "上传图片失败");
      }
    });
  }
}
