/*
 * @author lsy
 * @date   2019-12-04
 **/
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gengmei_app_face/HomeModel/page/age/AgePage.dart';
import 'package:gengmei_app_face/HomeModel/page/ai/AIPage.dart';
import 'package:gengmei_app_face/HomeModel/page/detect/DetectFacePage.dart';
import 'package:gengmei_app_face/HomeModel/page/star/StarPage.dart';
import 'package:gengmei_app_face/commonModel/GMBase.dart';
import 'package:gengmei_app_face/commonModel/toast/toast.dart';
import 'package:gengmei_app_face/commonModel/util/IUImageUtil.dart';
import 'dart:ui' as ui;

import 'package:gengmei_app_face/commonModel/util/JumpUtil.dart';

import '../../../main.mark.dart';

class HomeModel extends BaseModel {
  LiveData<UIHeadBean> headLive = new LiveData();

  @override
  void dispose() {
    headLive.dispost();
  }

  gotoAct(File file, int pos, BuildContext context) {
    if (file != null) {

      if (pos == 2) {
        JumpUtil.jumpLeft(context, DetectFacePage(file.path)).then((value){
          if(value!=null&&value is List){
            senSDK(file.path,value[0],value[1]);
          }
        });
        return;
      }
      RouterCenterImpl()
          .findAiRouter()
          .detectImageByPage(context, file.path)
          .then((value) {
        if (value != null && value.isNotEmpty) {
          if (pos == 1) {
            var agePage = AIPage(value);
            JumpUtil.jumpLeft(context, agePage);
          }
//          else if (pos == 2) {
//            var starPage = StarPage(value);
//            JumpUtil.jumpLeft(context, starPage);
//          }
        }
      });
    } else {
      Toast.show(context, "没有选择图片");
    }
  }

  void loadData(BuildContext context, String url) {
    headLive.notifyView(new UIHeadBean());
    IUImageUtil.getIUImage(url, true).listen((value) {
      headLive.data.img = value;
      headLive.notifyView(headLive.data);
    }).onError((error) {
      Toast.show(context, error.toString());
      print(error.toString());
    });
    IUImageUtil.getIUImage("images/head.png", false).listen((value) {
      headLive.data.icon = value;
      headLive.notifyView(headLive.data);
    }).onError((error) {
      Toast.show(context, error.toString());
      print(error.toString());
    });
  }
}

class UIHeadBean {
  ui.Image img;
  ui.Image icon;
}
