/*
 * @author lsy
 * @date   2019-12-04
 **/
import 'package:flutter/cupertino.dart';
import 'package:gengmei_app_face/commonModel/GMBase.dart';
import 'package:gengmei_app_face/commonModel/toast/toast.dart';
import 'dart:ui' as ui;

import 'package:gengmei_app_face/commonModel/util/IUImageUtil.dart';

class HelpModel extends BaseModel {
  LiveData<ui.Image> imageLive = new LiveData();

  getImage(BuildContext context, String url) {
    IUImageUtil.getIUImage(url, true).listen((value) {
      imageLive.notifyView(value);
    }).onError((error) {
      Toast.show(context, error.toString());
      print(error.toString());
    });
  }

  @override
  void dispose() {
    imageLive.dispost();
  }
}
