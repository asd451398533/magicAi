import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserChangeWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return UserChangePageWidgetState();
  }
}

class UserChangePageWidgetState extends State<UserChangeWidget> {
  var accountController = new TextEditingController();

  @override
  void dispose() {
    super.dispose();
    accountController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("设置昵称"),
          centerTitle: true,
        ),
        body: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(16, 30, 16, 0),
              width: double.maxFinite,
              height: 50,
              child: TextField(
                  maxLength: 6,
                  cursorColor: Colors.black,
                  controller: accountController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10.0),
                    icon: Icon(
                      Icons.supervised_user_circle,
                      color: Colors.black,
                    ),
//                    labelText: '请输入用户名',
//                    labelStyle: TextStyle(color: Colors.black),
                  )),
            ),
            Container(
                margin: EdgeInsets.fromLTRB(16, 50, 16, 0),
                width: double.maxFinite,
                height: 50,
                child: OutlineButton(
                  onPressed: () {
//                    Provider.of<UserProvide>(context)
//                        .saveUserName(context,accountController.text);
                  },
                  child: Text("确定"),
                  textColor: Colors.red,
                  splashColor: Colors.green,
                  highlightColor: Colors.black,
                  shape: BeveledRectangleBorder(
                    side: BorderSide(
                      color: Colors.red,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ))
          ],
        ));
  }
}
