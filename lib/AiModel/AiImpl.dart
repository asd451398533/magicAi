/*
 * @author lsy
 * @date   2019-09-16
 **/
import 'package:flutter/material.dart';
import 'package:gengmei_app_face/AiModel/AiRouter.dart';
import 'package:gengmei_app_face/AiModel/bean/GMUploadImgBean.dart';
import 'package:gengmei_app_face/AiModel/page/detect/DetectPage.dart';
import 'package:gengmei_app_face/AiModel/repository/DetectRepository.dart';
import 'package:gengmei_app_face/commonModel/bean/LandMarkBean.dart';
import 'package:rxdart/src/observables/observable.dart';

class AiImpl implements AiRouter {
  @override
  Future<String> detectImageByPage(
      BuildContext context, String filePath) async {
    return await Navigator.push(context,
        new MaterialPageRoute(builder: (context) => DetectPage(filePath)));
  }

  @override
  Observable<GMUploadImgBean> uploadImg(String filePath) {
    return DetectRepository.getInstance().uploadImgGM(filePath);
  }

  @override
  Observable<LandMarkBean> getLandMark(String url) {
    return DetectRepository.getInstance().getLandMark(url);
  }


}
