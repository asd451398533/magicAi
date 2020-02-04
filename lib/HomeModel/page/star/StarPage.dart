import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gengmei_app_face/HomeModel/page/star/StarModel.dart';
import 'package:gengmei_app_face/commonModel/base/BaseComponent.dart';

class StarPage extends StatefulWidget {
  String filePath;
  String title;

  StarPage(this.filePath) {}

  @override
  State<StatefulWidget> createState() {
    return StarState( filePath);
  }
}

class StarState extends State<StarPage> {
  String filePath;
  String title;
  bool isInit=false;
  StarModel _model;

  StarState(String filePath){
    _model=StarModel(filePath);
  }

  @override
  void initState() {
    _model.exec(context);
    super.initState();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title,
              style: new TextStyle(
                color: Colors.black,
              )),
          leading: IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: Colors.black,
              ),
              onPressed: () {
                _model.quitTask(context);
              }),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: <Widget>[
            Expanded(child: Container()),
            StreamBuilder(
              stream: _model.errorString.stream,
              initialData: _model.errorString.data,
              builder: (con,data){
                if(data.data==null){
                  return CircularProgressIndicator();
                }
                return Container(
                  child: baseText(data.data, 15, Colors.black),
                );
              },
            ),
            Container(
              height: 16,
            ),
            Center(
              child: Text("明星融合中.."),
            ),
            Expanded(child: Container()),
          ],
        ));
  }
}
