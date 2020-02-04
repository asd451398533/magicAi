/*
 * @author lsy
 * @date   2019-12-20
 **/
import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gengmei_app_face/HomeModel/page/ai/AIModel.dart';
import 'package:gengmei_app_face/commonModel/base/BaseComponent.dart';
import 'package:gengmei_app_face/commonModel/base/BaseState.dart';

class AIPage extends StatefulWidget {
  String url;

  AIPage(this.url);

  @override
  State<StatefulWidget> createState() {
    return AIState();
  }
}

class AIState extends BaseState<AIPage> {
  AIModel _model;

  @override
  void initState() {
    _model = AIModel();
    _model.getResult(context, widget.url);
    super.initState();
  }

  @override
  Widget buildItem(BuildContext context) {
    return Scaffold(
      appBar: baseAppBar(
          backClick: () {
            Navigator.pop(context);
          },
          title: "AI聚合接口",
          centerTitle: true),
      body: Stack(
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints.expand(),
            child: ExtendedImage.network(
              widget.url,
              fit: BoxFit.contain,
              //enableLoadState: false,
              mode: ExtendedImageMode.gesture,
              initGestureConfigHandler: (state) {
                return GestureConfig(
                  minScale: 0.9,
                  animationMinScale: 0.7,
                  maxScale: 3.0,
                  animationMaxScale: 3.5,
                  speed: 1.0,
                  inertialSpeed: 100.0,
                  initialScale: 1.0,
                  inPageView: false,
                  initialAlignment: InitialAlignment.center,
                );
              },
            ),
          ),
          StreamBuilder(
            stream: _model.wrongLive.stream,
            initialData: _model.wrongLive.data,
            builder: (con, data) {
              if (data.data == null) {
                return Container();
              }
              return Container(
                alignment: Alignment.center,
                width: double.maxFinite,
                height: double.maxFinite,
                color: Color(0x55E3F2FD),
                child: baseText(data.data, 20, Colors.red),
              );
            },
          ),
          StreamBuilder(
            stream: _model.messageLive.stream,
            initialData: "识别图片中...",
            builder: (con, data) {
              return Positioned(
                  child: SingleChildScrollView(
                    child: Container(
                      color: Colors.black38,
                      child: baseText(data.data, 16, Colors.red),
                    ),
                  ));
            },
          ),
        ],
      ),
    );
  }
}
