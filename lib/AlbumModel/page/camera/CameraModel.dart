/*
 * @author lsy
 * @date   2020-02-26
 **/
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:gengmei_app_face/commonModel/GMBase.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart';


Future<List<String>> paseWXLoginBean(String savePath) async{
  print("SAVE ${savePath}");
//  String scareSavePath="${appDocDir.path}/PIC_SCARE_${DateTime.now().millisecondsSinceEpoch}.jpeg";
  String scareSavePath="${savePath}-PIC_SCARE_${DateTime.now().millisecondsSinceEpoch}.jpeg";

  var readAsBytesSync = await File(savePath).readAsBytes();
  Image image = decodeImage(readAsBytesSync);
//  if(Platform.isAndroid&&before){
    image = flip(image,Flip.horizontal);
    await File(savePath).writeAsBytes(encodeJpg(image),flush: true);
//  }
  Image thumbnail = copyResize(image, width: 320);
  await File(scareSavePath).writeAsBytes(encodeJpg(thumbnail),flush: true);
  return [savePath,scareSavePath];
}

class CameraModel extends BaseModel{

  LiveData<String> imageLive=LiveData();
  LiveData<bool> maskLive =new LiveData();



  Future<List<String>> tackPic(CameraController controller,bool before) async{
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String savePath="${appDocDir.path}/PIC_${DateTime.now().millisecondsSinceEpoch}.jpeg";
    await controller.takePicture(savePath);
//    return [savePath,scareSavePath];
  return compute(paseWXLoginBean,savePath);
  }

  @override
  void dispose() {
    imageLive.dispost();
    maskLive.dispost();
  }

}