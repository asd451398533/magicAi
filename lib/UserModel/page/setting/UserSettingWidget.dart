import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gengmei_app_face/commonModel/picker/Pickers.dart';
import 'package:gengmei_app_face/commonModel/util/WindowUtil.dart';

import 'UserChangeWidget.dart';

class UserSettingWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return UserSettingPageWidgetState();
  }
}

class UserSettingPageWidgetState extends State<UserSettingWidget> {
  var picker;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("MagicAi"),
          centerTitle: true,
        ),
        body: Stack(
          children: <Widget>[
//        CachedNetworkImage(
//          width: double.maxFinite,
//          height: double.maxFinite,
//          imageUrl: "http://pic1.win4000.com/wallpaper/c/53cdd1f7c1f21.jpg",
//          fit: BoxFit.cover,
//        ),
            Column(
              children: <Widget>[
                Container(
                    margin: EdgeInsets.fromLTRB(16, 30, 16, 0),
                    width: double.maxFinite,
                    height: 70,
                    child: GestureDetector(
                      onTap: () {
                        picker = showPicker(context, 0, () {
//                          Provider.of<UserProvide>(context).camera(context);
                          Navigator.pop(context);
                        }, () {
//                          Provider.of<UserProvide>(context).album(context);
                          Navigator.pop(context);
                        });
                      },
                      child: Row(
                        children: <Widget>[
                          Text("头像"),
                          Expanded(
                            child: Container(),
                          ),
                          Hero(
                              tag: "USER_HEAD_NONE",
                              child: new CircleAvatar(
                                radius: 36.0,
                                backgroundImage: AssetImage(
                                  "asset/images/as.jpg",
                                ),
                              ))
//                              ClipOval(
//                                child: Image.asset(
//                                  "asset/images/head.png",
//                                  height: 100,
//                                ),
//                              ))

                          ,
                          Icon(Icons.chevron_right)
                        ],
                      ),
                    )),
                Container(
                  margin: EdgeInsets.fromLTRB(16, 5, 16, 5),
                  width: double.maxFinite,
                  height: 1,
                  color: Colors.grey,
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => UserChangeWidget()));
                    },
                    child: Container(
                      margin: EdgeInsets.fromLTRB(16, 10, 16, 0),
                      height: 50,
                      width: double.maxFinite,
                      child: Row(
                        children: <Widget>[
                          Text("昵称"),
                          Expanded(
                            child: Container(),
                          ),
                          Hero(
                            tag: "USER_NAME",
                            child: Text(
                              "welcome",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          Icon(Icons.chevron_right)
                        ],
                      ),
                    ))
              ],
            )
//        Center(
//            child: Container(
//              height: 230,
//          child: Column(
//
//            children: <Widget>[
//
//              Expanded(
//                child: Container(),
//              ),
//              Hero(
//                tag: "USER_NAME",
//                child: Text(
//                  "${Provider.of<UserProvide>(context).userName}",
//                  style: TextStyle(fontSize: 30, color: Colors.black),
//                ),
//              ),
//            ],
//          ),
//        )

//
////
//            )
          ],
        ));
  }
}
