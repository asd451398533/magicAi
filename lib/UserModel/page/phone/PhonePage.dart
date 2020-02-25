/*
 * @author lsy
 * @date   2020-02-12
 **/
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gengmei_app_face/UserModel/service/local/UserLocal.user.dart';
import 'package:gengmei_app_face/commonModel/base/BaseComponent.dart';
import 'package:gengmei_app_face/commonModel/base/BaseState.dart';
import 'package:gengmei_app_face/commonModel/ui/ALColors.dart';
import 'package:toast/toast.dart';

import 'PhoneModel.dart';

class PhonePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PhoneState();
}

class PhoneState extends BaseState<PhonePage> {
  PhoneModel _model = PhoneModel();
  TextEditingController editingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget buildItem(BuildContext context) {
    return Scaffold(
      appBar: baseAppBar(
          title: "输入手机号",
          centerTitle: true,
          backClick: () {
            Navigator.pop(context);
          }),
      body: Column(
        children: <Widget>[
//        Expanded(
//          child: Container(),
//        ),
          Container(
            height: 15,
          ),
          Container(
            margin: EdgeInsets.only(left: 15, right: 15),
            child: textField(),
          ),
          Container(
            margin:  EdgeInsets.only(left: 15, right: 15),
            child: FlatButton(
              onPressed: (){
                if(editingController.text.length==11&&isChinaPhoneLegal(editingController.text)){
                  UserLocalImpl().savephone(editingController.text);
                  Navigator.pop(context,editingController.text);
                }else{
                  Toast.show("请输入正确手机号", context,gravity: 1);
                }
              },
              child: baseText("确认", 15, Colors.blue),
            ),
          ),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }

  static bool isChinaPhoneLegal(String str) {
    return new RegExp('^((13[0-9])|(15[^4])|(166)|(17[0-8])|(18[0-9])|(19[8-9])|(147,145))\\d{8}\$').hasMatch(str);
  }

  Widget textField() {
    return TextField(
      style: TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: "请填写手机号",
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none),
        filled: true,
        fillColor: ALColors.ColorF7F6FA,
      ),
      maxLines: 1,
      maxLength: 11,
      keyboardType: TextInputType.number,
      enableInteractiveSelection: true,
      autocorrect: false,
      autofocus: false,
      textInputAction:
          Platform.isAndroid ? TextInputAction.done : TextInputAction.done,
      controller: editingController,
      minLines: null,
      onEditingComplete: () {
        print("COMPLETE");
      },
      onSubmitted: (text) {},
    );
  }
}
