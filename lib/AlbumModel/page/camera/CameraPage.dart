/*
 * @author lsy
 * @date   2020-02-26
 **/
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gengmei_app_face/AlbumModel/util/AlbumUtil.dart';
import 'package:gengmei_app_face/commonModel/base/BaseComponent.dart';
import 'package:gengmei_app_face/commonModel/camera/CameraInstance.dart';
import 'package:gengmei_app_face/commonModel/toast/toast.dart';

import 'CameraModel.dart';

class CameraPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CameraState();
}

class CameraState extends State<CameraPage> with WidgetsBindingObserver {
  CameraController controller;
  CameraModel _model = CameraModel();
  bool beforeCamera = true;
  bool takingPic = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    onNewCameraSelected();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        onNewCameraSelected();
      }
    }
  }

  void onNewCameraSelected() async {
    if (controller != null) {
      await controller.dispose();
    }
    try {
      CameraDescription nowCamera = beforeCamera
          ? CameraInstance.getInstance().getFontCamera()
          : CameraInstance.getInstance().getBackCamera();
      controller = CameraController(nowCamera, ResolutionPreset.veryHigh);
      await controller.initialize();

      if (!mounted) {
        return;
      }
      setState(() {});
    } catch (e) {
      print(e);
      Toast.show(context, "打开相机失败");
    }
  }

  void switchCamera() {
    beforeCamera = !beforeCamera;
    onNewCameraSelected();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.black,
            ),
            controller != null && controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: CameraPreview(controller))
                : Container(),
            controller != null && controller.value.isInitialized
                ? Positioned(
                    bottom: 0,
                    child: Container(
                      color: Colors.black,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).size.width /
                              controller.value.aspectRatio,
                    ),
                  )
                : Container(),
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                width: 100,
                height: 100,
                child: StreamBuilder<String>(
                  stream: _model.imageLive.stream,
                  initialData: _model.imageLive.data,
                  builder: (c, data) {
                    if (data.data == null) {
                      return Container();
                    }
                    return Image.file(File(data.data));
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 50,
              child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: InkWell(
//                behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (takingPic) {
                        return;
                      }
                      takingPic = true;
                      _model.maskLive.notifyView(true);
                      _model.tackPic(controller, beforeCamera).then((value) {
                        Navigator.pop(context, value);
                      }).catchError((error) {
                        print(error.toString());
                        takingPic = false;
                        Toast.show(context, "拍照出错");
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.blue, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      width: 50,
                      height: 50,
                      child: Icon(
                        Icons.camera_alt,
                        size: 22,
                      ),
                    ),
                  )),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  switchCamera();
                },
                child: Container(
                  alignment: Alignment.topRight,
                  width: 50,
                  height: 60,
                  padding: EdgeInsets.only(top: 30, right: 15),
                  child: Icon(
                    Icons.sync,
                    size: 22,
                  ),
                ),
              ),
            ),
            Positioned(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  alignment: Alignment.topLeft,
                  width: 50,
                  height: 60,
                  padding: EdgeInsets.only(top: 30, left: 15),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 22,
                  ),
                ),
              ),
            ),
            controller != null && controller.value.isInitialized
                ? Container()
                : Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.black,
                  ),
            StreamBuilder(
              stream: _model.maskLive.stream,
              initialData: false,
              builder: (c, data) {
                if (data.data) {
                  return mask();
                }
                return Container();
              },
            )
          ],
        ));
  }

  Widget mask() {
    return Positioned(
      top: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Opacity(
            opacity: 0.5,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width /
                  controller.value.aspectRatio,
              decoration: BoxDecoration(color: Colors.grey.shade200),
              child: loadingItem(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    _model.dispose();
    super.dispose();
  }
}
