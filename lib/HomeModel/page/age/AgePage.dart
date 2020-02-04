import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gengmei_app_face/HomeModel/page/age/AgeModel.dart';
import 'package:gengmei_app_face/commonModel/view/seekbar/seekbar.dart';

class AgePage extends StatefulWidget {
  final String url;

  AgePage(this.url);

  @override
  State<StatefulWidget> createState() => AgeState(url);
}

class AgeState extends State<AgePage> {
  static const ACTION_SEARCH = "search";
  AgeModel _model;

  AgeState(String url) {
    _model = new AgeModel(url);
  }

  @override
  void initState() {
    _model.init();
    super.initState();
  }

  Center getProgressDialog() {
    return new Center(child: new CircularProgressIndicator());
  }

  getSeekBar() {
    return Padding(
        padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
//                  InkWell(
//                    child: Container(
//                      height: 20,
//                      child: Provide(builder: (BuildContext context,
//                          Widget child, MainHomeProvide value) {
//                        return mProvide.male ? Container() : Icon(Icons.check);
//                      }),
//                    ),
//                    onTap: () {
//                      mProvide.male = false;
//                      mProvide.notifyListeners();
//                    },
//                  ),
                  Text("是女生照片"),
                ],
              ),
            ),
            Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  width: 200,
                  child: SeekBar(
                      indicatorRadius: 0.0,
                      progresseight: 9,
                      value: 20,
                      hideBubble: false,
                      alwaysShowBubble: true,
                      bubbleRadius: 14,
                      bubbleColor: Colors.purple,
                      bubbleTextColor: Colors.white,
                      bubbleTextSize: 14,
                      bubbleMargin: 1,
                      bubbleInCenter: false,
                      onValueChanged: (v) {
                        _model.age = v.value;
                      }),
                ),
//                Provide(builder: (BuildContext context, Widget child,
//                    MainHomeProvide value) {
//                  return Text("图片的年龄为:${value.age.ceil()}",
//                      style: TextStyle(fontSize: 10));
//                })
              ],
            ),
            Expanded(
              child: Column(
                children: <Widget>[
//                  InkWell(
//                    child: Container(
//                      height: 20,
//                      child: Provide(builder: (BuildContext context,
//                          Widget child, MainHomeProvide value) {
//                        return mProvide.male ? Icon(Icons.check) : Container();
//                      }),
//                    ),
//                    onTap: () {
//                      _model.male = true;
//                    },
//                  ),
                  Text("是男士照片")
                ],
              ),
            )
          ],
        ));
  }

  getListView(BuildContext context) {
    return Container(
        height: 80,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _model.bottomList.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                  onTap: () {
                    _model.click(index, context);
                  },
                  child: Container(
                      padding: new EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Column(
                        children: <Widget>[
                          Stack(
                            alignment: const Alignment(1, 1),
                            children: <Widget>[
                              Image.asset(
                                _model.bottomList[index].imagePath,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                              StreamBuilder<int>(
                                stream: _model.checkIndexLive.stream,
                                initialData: _model.checkIndexLive.data,
                                builder: (con, data) {
                                  if (data.data == null || data.data != index) {
                                    return Container();
                                  }
                                  return Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Icon(Icons.check,
                                        size: 16, color: Colors.amber),
                                  );
                                },
                              )
                            ],
                          ),
                          Container(
                            padding: new EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: Center(
                              child: Text(_model.bottomList[index].text),
                            ),
                          )
                        ],
                      )));
            }));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              new IconButton(
                  icon: new Icon(
                    Icons.file_download,
                    color: Colors.black,
                  ),
                  tooltip: 'Add Alarm',
                  onPressed: () {
                    _model.saveToSdCard(context);
                  }),
            ],
            leading: IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: Colors.black,
                ),
                onPressed: () => Navigator.of(context).pop()),
            centerTitle: true,
            backgroundColor: Colors.white,
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  child: Center(
                      child: Stack(
                    children: <Widget>[
                      Center(
                          child: StreamBuilder(
                        stream: _model.showImageLive.stream,
                        initialData: _model.showImageLive.data,
                        builder: (con, data) {
                          if (data.data == null) {
                            return Container();
                          }
                          return CachedNetworkImage(
                            imageUrl: _model.netImagePath,
                            placeholder: (context, url) {
                              return CircularProgressIndicator();
                            },
                          );
                        },
                      ))
//
                    ],
                  )),
                ),
                flex: 1,
              ),
              getSeekBar(),
              getListView(context),
            ],
          ),
        ),
        onWillPop: () {
          Navigator.of(context).pop();
        });
  }
}
