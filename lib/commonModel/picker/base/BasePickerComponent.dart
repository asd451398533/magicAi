/*
 * @author lsy
 * @date   2019-10-21
 **/
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:gengmei_app_face/commonModel/picker/base/BaseCenterPicker.dart';

class BaseLoadingItem implements ICenterPicker {
  final String loadingText;

  BaseLoadingItem(this.loadingText);

  @override
  Widget build(BuildContext context) {
    return Center(
      ///弹框大小
      child: new Container(
        width: 120.0,
        height: 120.0,
        child: new Container(
          ///弹框背景和圆角
          decoration: ShapeDecoration(
            color: Color(0xffffffff),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
          ),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new CircularProgressIndicator(),
              new Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                ),
                child: new Text(
                  loadingText,
                  style: new TextStyle(fontSize: 16.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
