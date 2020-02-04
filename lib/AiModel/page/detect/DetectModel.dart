/*
 * @author lsy
 * @date   2019-09-16
 **/
import 'package:flutter/cupertino.dart';
import 'package:gengmei_app_face/AiModel/repository/DetectRepository.dart';
import 'package:gengmei_app_face/commonModel/live/BaseModel.dart';
import 'package:gengmei_app_face/commonModel/live/LiveData.dart';
import 'package:gengmei_app_face/commonModel/toast/toast.dart';

class DetectModel implements BaseModel {
  LiveData<String> resultLive = LiveData();

  final String filePath;

  DetectModel(this.filePath);

  void detectImg(BuildContext context) {
    if (filePath == null || filePath.isEmpty) {
      resultLive.notifyView("没有传递filePath");
    }
    print("！！！！  ${filePath}");
    DetectRepository.getInstance().detectFace(filePath).listen((value) {
      if (value == "success") {
        resultLive.notifyView("检测到人脸，上传图片中...");
        _uploadImg(context);
      }else{
        resultLive.notifyView(value);
      }
    }).onError((error) {
      print(error);
      Toast.show(context, error.toString());
    });
  }

  void _uploadImg(BuildContext context) {
//    DetectRepository.getInstance().uploadImg(filePath).listen((data) {
//      if (data != null) {
//        Navigator.pop(context, data);
//      }
//    }).onError((error) {
//      resultLive.notifyView("上传图片失败!");
//      print(error);
//      Toast.show(context, error.toString());
//    });
    DetectRepository.getInstance().uploadImgGM(filePath).listen((value){
      if(value.fileUrl!=null){
        if(value.fileUrl.contains("half")){
          Navigator.pop(context,value.fileUrl.replaceAll("half", "w"));
        }else{
          Navigator.pop(context,value.fileUrl);
        }
      }else{
        resultLive.notifyView("上传图片失败!");
      }
    }).onError((error){
      resultLive.notifyView("上传图片失败!");
      print(error);
      Toast.show(context, error.toString());
    });
  }

  @override
  void dispose() {
    resultLive.dispost();
  }
}
