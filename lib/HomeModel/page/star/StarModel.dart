/*
 * @author lsy
 * @date   2019-12-04
 **/
import 'package:flutter/material.dart';
import 'package:gengmei_app_face/HomeModel/page/video/VideoPage.dart';
import 'package:gengmei_app_face/HomeModel/repo/HomeRepo.dart';
import 'package:gengmei_app_face/commonModel/GMBase.dart';
import 'package:gengmei_app_face/commonModel/toast/toast.dart';
import 'package:gengmei_app_face/commonModel/util/JumpUtil.dart';

class StarModel extends BaseModel{
  LiveData<String> errorString=new LiveData();
  String filePath;
  StarModel(this.filePath);

  exec(BuildContext context) {
    HomeRepo.getInstance().execSTAR(filePath).listen((value) {
      var videoPage = VideoPage(value);
      JumpUtil.jumpLeft(context, videoPage);
    }).onError((error) {
      Toast.show(context,error.toString());
      print(error.toString());
      errorString.notifyView(error.toString());
    });
  }



  void quitTask(BuildContext context) {
    quitApp().whenComplete(() {
      Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    errorString.dispost();
  }

}