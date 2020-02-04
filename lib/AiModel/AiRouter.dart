/*
 * @author lsy
 * @date   2019-09-16
 **/
import 'package:flutter/cupertino.dart';
import 'package:flutter_common/Annotations/RouterBaser.dart';
import 'package:flutter_common/Annotations/anno/Router.dart';
import 'package:gengmei_app_face/AiModel/AiImpl.dart';
import 'package:gengmei_app_face/commonModel/bean/LandMarkBean.dart';
import 'package:rxdart/rxdart.dart';

import 'bean/GMUploadImgBean.dart';
@Router("AiRouter",AiImpl,true)
abstract class AiRouter implements RouterBaser{

  Future<String> detectImageByPage(BuildContext context,String filePath);

  Observable<GMUploadImgBean> uploadImg(String filePath);

  Observable<LandMarkBean> getLandMark(String url);
}