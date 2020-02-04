import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:gengmei_app_face/AiModel/page/detect/DetectModel.dart';

class DetectPage extends StatefulWidget {
  DetectModel _model;

  DetectPage(String path) {
    _model = DetectModel(path);
  }

  @override
  State<StatefulWidget> createState() => DetectState(_model);
}

class DetectState extends State<DetectPage> {
  DetectModel _model;

  DetectState(this._model);

  @override
  void initState() {
    super.initState();
    _model.detectImg(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              leading: IconButton(
                  icon: Icon(
                    Icons.chevron_left,
                    color: Colors.black,
                  ),
                  onPressed: () => Navigator.pop(context, "")),
            ),
            body: StreamBuilder<String>(
                stream: _model.resultLive.stream,
                initialData: "识别人脸中...",
                builder: (context, value) {
                  return Center(
                    child: Text(value.data),
//                      Image.file(File(_model.filePath))
                  );
                })),
        onWillPop: () {
          Navigator.pop(context, "");
        });
  }

  @override
  void dispose() {
    super.dispose();
    _model.dispose();
  }
}
