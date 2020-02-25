/*
 * @author lsy
 * @date   2020-01-02
 **/
import 'dart:io';
import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gengmei_app_face/HomeModel/page/want/WantModel.dart';
import 'package:gengmei_app_face/HomeModel/page/want/WantView.dart';
import 'package:gengmei_app_face/commonModel/base/AppBase.dart';
import 'package:gengmei_app_face/commonModel/base/BaseComponent.dart';
import 'package:gengmei_app_face/commonModel/base/BaseState.dart';
import 'package:gengmei_app_face/commonModel/ui/ALColors.dart';

class WantPage extends StatefulWidget {
  final String url;
  final String showText;
  final String oriImg;

  WantPage(this.url, this.showText, this.oriImg);

  @override
  State<StatefulWidget> createState() => WantPageState();
}

class WantPageState extends BaseState<WantPage> {
  WantModel _model = WantModel();
  int index;

  @override
  void initState() {
//    List<String> list = [
//      "原图",
//      "初恋脸",
//      "小鹿脸",
//      "幼幼脸",
//      "日系脸",
//      "性感甜美脸",
//      "知性优雅脸",
//      "古典脸",
//      "妩媚脸"
//    ];
    List<String> list = [
      "原图",
      "幼幼脸",
      "网红脸",
      "日系脸",
      "变年轻",
      "初恋脸",
      "小鹿脸",
      "优雅脸",
      "韩系脸",
      "测试脸"
    ];
//    index = list.indexOf(widget.showText);
    index=Random().nextInt(9);
    if (index == null || index <= 0) {
      index = 1;
    }
    print("--======= ${index}");
    _model.init(context, widget.url, index);
    super.initState();
  }

  @override
  Widget buildItem(BuildContext context) {
    return Scaffold(
      appBar: baseAppBar(
        centerTitle: true,
        backClick: () => Navigator.pop(context),
        title: "诉求页面",
      ),
      //ExtendedImage.file(
      //              File(widget.url),
      //              fit: BoxFit.fitWidth,
      //              //enableLoadState: false,
      //              mode: ExtendedImageMode.gesture,
      //              initGestureConfigHandler: (state) {
      //                return GestureConfig(
      //                  minScale: 0.9,
      //                  animationMinScale: 0.7,
      //                  maxScale: 3.0,
      //                  animationMaxScale: 3.5,
      //                  speed: 1.0,
      //                  inertialSpeed: 100.0,
      //                  initialScale: 1.0,
      //                  inPageView: false,
      //                  initialAlignment: InitialAlignment.center,
      //                );
      //              },
      //            ),
      body: Stack(
        children: <Widget>[
          ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child: StreamBuilder<WantBean>(
                stream: _model.wantLive.stream,
                initialData: _model.wantBean,
                builder: (c, data) {
                  if (data.data == null ||
                      data.data.image == null ||
                      data.data.showOri) {
                    return ExtendedImage.file(
                      File(widget.oriImg),
                      fit: BoxFit.fitWidth,
                    );
                  }
                  return Container(
                      width: double.maxFinite,
                      height: double.maxFinite,
                      child: CustomPaint(
                        painter: WantView(context, data.data),
                      ));
                },
              )),
          Center(
            child: StreamBuilder(
              stream: _model.resultLive.stream,
              initialData: _model.resultLive.data,
              builder: (c, data) {
                if (data.data == null) {
                  return baseText("生成中，请耐心等待...", 15, Colors.blue);
                }
                return Container();
              },
            ),
          ),
          Positioned(
            right: 25,
            bottom: 120,
            child: GestureDetector(
              onTapDown: (de) {
                print("TAP DOWNNN  ");
                _model.wantBean.showOri = true;
                _model.wantLive.notifyView(_model.wantBean);
              },
              onTapUp: (de) {
                print("TAP onTapUp  ");
                _model.wantBean.showOri = false;
                _model.wantLive.notifyView(_model.wantBean);
              },
              onTapCancel: () {
                print("TAP onTapCancel  ");
                _model.wantBean.showOri = false;
                _model.wantLive.notifyView(_model.wantBean);
              },
              child: Container(
                alignment: Alignment.center,
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xffff0000),
                        blurRadius: 5.0,
                      ),
                    ]),
                child: baseText("对比", 12, ALColors.ColorFFFFFF),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              height: 80,
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context, 1);
                    },
                    child: Container(
                      width: 80,
                      child: baseText("重新微整", 15, Colors.black),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.maxFinite,
                      height: double.maxFinite,
                      alignment: Alignment.center,
                      child: StreamBuilder(
                        stream: _model.faceResultLive.stream,
                        initialData: _model.faceResultLive.data,
                        builder: (c, data) {
                          String word;
                          if (data.data == null) {
                            word = widget.showText;
                          } else {
                            word =
                                "分析出您的脸型为：${data.data} \n希望是:${widget.showText}";
                          }
                          return baseText(word, 15, Colors.black);
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
