/*
 * @author lsy
 * @date   2020-01-17
 **/
import 'package:flutter_common/Annotations/anno/ServiceCenter.dart';
import 'package:flutter_common/Annotations/anno/Upload.dart';
import 'package:flutter_common/Annotations/anno/UploadFilePath.dart';
import 'package:gengmei_app_face/AiModel/bean/GMUploadImgBean.dart';

@ServiceCenter()
abstract class AiApi{

  @Upload("files/upload/")
  GMUploadImgBean uploadImgGM(@UploadFilePath("file")String path);
}