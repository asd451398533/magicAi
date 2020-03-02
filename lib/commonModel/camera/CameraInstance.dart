/*
 * @author lsy
 * @date   2020-02-27
 **/
import 'package:camera/camera.dart';

class CameraInstance {
  static List<CameraDescription> cameras;

  static CameraInstance _instance;

  static CameraInstance getInstance() {
    if (_instance == null) {
      _instance = CameraInstance._();
    }
    return _instance;
  }

  CameraInstance._() {
    availableCameras().then((value) {
      cameras = value;
    });
  }

  CameraDescription getFontCamera(){
    CameraDescription cameraDescription;
    cameras.forEach((e){
      if(e.lensDirection==CameraLensDirection.front){
        cameraDescription=e;
      }
    });
    return cameraDescription;
  }

  CameraDescription getBackCamera(){
    CameraDescription cameraDescription;
    cameras.forEach((e){
      if(e.lensDirection==CameraLensDirection.back){
        cameraDescription=e;
      }
    });
    return cameraDescription;
  }

}
