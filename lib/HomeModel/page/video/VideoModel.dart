/*
 * @author lsy
 * @date   2019-12-04
 **/
import 'package:flutter/material.dart';
import 'package:gengmei_app_face/HomeModel/repo/HomeRepo.dart';
import 'package:gengmei_app_face/commonModel/GMBase.dart';
import 'package:gengmei_app_face/commonModel/toast/toast.dart';

class VideoModel extends BaseModel {
  LiveData<String> videoLive = new LiveData();
  double ratio = 1 / 1;

  init(String filePath){
    videoLive.notifyView(filePath);
  }

  @override
  void dispose() {
    videoLive.dispost();
  }

  void execStarLong(BuildContext context) {
    videoLive.notifyView(null);
    HomeRepo.getInstance().execSTARL().listen((path) {
      ratio = 375 / 577;
      videoLive.notifyView(path);
    }).onError((error) {
      Toast.show(context, error.toString());
      print(error);
    });
  }
}
