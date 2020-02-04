import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gengmei_app_face/HomeModel/bean/ChangeBean.dart';
import 'package:gengmei_app_face/HomeModel/repo/HomeRepo.dart';
import 'package:gengmei_app_face/commonModel/GMBase.dart';
import 'package:gengmei_app_face/commonModel/picker/base/BasePickerComponent.dart';
import 'package:gengmei_app_face/commonModel/toast/toast.dart';

class AgeModel extends BaseModel {
  LiveData<int> checkIndexLive = new LiveData();
  LiveData<String> showImageLive = new LiveData();
  bool male = true;
  String imageUrl;
  String netImagePath;
  StringBuffer stringBuffer = new StringBuffer();

  File imageFile;
  bool isNativePic=true;
  List<ChangeBean> bottomList = new List();

  int checkIndex = -1;

  int showTime = 0;

  bool loading = false;
  HomeRepo _homeRepo = HomeRepo.getInstance();

  double age = 20;

  AgeModel(this.imageUrl);

  init() {
    bottomList.add(ChangeBean("asset/images/head.png", "变10岁"));
    bottomList.add(ChangeBean("asset/images/head.png", "变20岁"));
    bottomList.add(ChangeBean("asset/images/head.png", "变30岁"));
    bottomList.add(ChangeBean("asset/images/head.png", "变40岁"));
    bottomList.add(ChangeBean("asset/images/head.png", "变50岁"));
    bottomList.add(ChangeBean("asset/images/head.png", "变60岁"));
    bottomList.add(ChangeBean("asset/images/head.png", "变70岁"));
    bottomList.add(ChangeBean("asset/images/head.png", "变80岁"));
    bottomList.add(ChangeBean("asset/images/head.png", "变90岁"));
    bottomList.add(ChangeBean("asset/images/head.png", "变100岁"));
    bottomList.add(ChangeBean("asset/images/head.png", "TODO"));
    bottomList.add(ChangeBean("asset/images/head.png", "TODO"));
    bottomList.add(ChangeBean("asset/images/head.png", "TODO"));
    bottomList.add(ChangeBean("asset/images/head.png", "TODO"));
    bottomList.add(ChangeBean("asset/images/head.png", "TODO"));
    bottomList.add(ChangeBean("asset/images/head.png", "TODO"));
    showImageLive.notifyView(imageUrl);
  }

  click(int index, BuildContext context) {
    stringBuffer.clear();
    if (index > 9) {
      Toast.show(context, "紧张开发中");
    } else {
      checkIndexLive.notifyView(index);
      BaseCenterPicker()
        ..setPicker(BaseLoadingItem("加载中..."))
        ..setCancelOutside(true)
        ..show(context);
      _homeRepo
          .startFace(imageUrl, age.ceil(), index * 10, male)
          .listen((value) {
        isNativePic=false;
        showImageLive.notifyView(value);
        Navigator.pop(context);
      }).onError((error) {
        Toast.show(context, "error:" + error.toString());
        Navigator.pop(context);
      });
    }
  }

  saveToSdCard(BuildContext context) {
    print(imageUrl + "   netUUURL   ");
    if (netImagePath != null && netImagePath.isNotEmpty) {
      print(netImagePath);
      _homeRepo.saveToSd(netImagePath).listen((value) {
        if (!value) {
          Toast.show(context, "保存失败");
        } else {
          Toast.show(context, "保存成功  保存在SD卡/TEMP目录下");
        }
      }).onError((error) {
        Toast.show(context, error.toString());
        print(error.toString());
      });
    }
  }

  @override
  void dispose() {
    checkIndexLive.dispost();
    showImageLive.dispost();
  }
}
