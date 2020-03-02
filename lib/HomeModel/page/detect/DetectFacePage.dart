/*
 * @author lsy
 * @date   2020-02-19
 **/
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gengmei_app_face/commonModel/base/BaseComponent.dart';
import 'package:gengmei_app_face/commonModel/base/BaseState.dart';
import 'package:gengmei_app_face/commonModel/ui/ALColors.dart';

import 'DetectFaceModel.dart';

class DetectFacePage extends StatefulWidget {
  final String filePath;
  DetectFacePage(this.filePath);
  @override
  State<StatefulWidget> createState() => DetectFaceState();
}

class DetectFaceState extends BaseState<DetectFacePage> {

  DetectFaceModel _model=DetectFaceModel();

  @override
  void initState() {
    _model.init(context,widget.filePath);
    super.initState();
  }

  @override
  Widget buildItem(BuildContext context) {
    return Scaffold(
      appBar: baseAppBar(
        backClick: (){
          Navigator.pop(context);
        },
        centerTitle: true,
        title: "ai检测面部",
      ),
      body: Container(
        child: StreamBuilder(
          stream: _model.messageLive.stream,
          initialData: _model.messageLive.data,
          builder: (c,data){
            if(data.data==null){
              return loadingItem();
            }
            return Center(
              child: baseText(data.data, 15, Colors.black),
            );
          },
        )
      ),
    );
  }
}
