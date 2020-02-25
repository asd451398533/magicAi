/*
 * @author lsy
 * @date   2019-10-13
 **/

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gengmei_app_face/res/GMRes.dart';

AppBar baseAppBar(
    {String title,
    List<Widget> action,
    bool centerTitle,
    VoidCallback backClick,
    Color backgroundColor}) {
  return baseAppBarChangeTitle(
      title: title == null
          ? Container()
          : baseText(title, 16, ALColors.Color323232),
      action: action,
      centerTitle: centerTitle,
      backClick: backClick,
      backgroundColor: backgroundColor);
}

AppBar baseAppBarChangeTitle(
    {Widget title,
    List<Widget> action,
    bool centerTitle,
    VoidCallback backClick,
    Color backgroundColor}) {
  return AppBar(
    backgroundColor:
        backgroundColor == null ? ALColors.ColorFFFFFF : backgroundColor,
    title: title,
    centerTitle: centerTitle,
    elevation: 0.0,
    leading: GestureDetector(
      onTap: backClick,
      child: Hero(
          tag: "left_arrow",
          child: Container(
              color: ALColors.ColorFFFFFF,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 22),
              width: 30,
              height: double.maxFinite,
              child: SvgPicture.asset(
                "images/left_arrow.svg",
                color: Color(0xff323232),
              ))),
    ),
    actions: action == null ? List<Widget>() : action,
  );
}

Text baseText(String text, double fontSize, Color color) {
  return Text(
    text,
    textScaleFactor: 1.0,
    textDirection: TextDirection.ltr,
    style: TextStyle(fontSize: fontSize, color: color,decoration: TextDecoration.none,),
  );
}

/**
 * 基础的liveView分割线
 */
Widget baseDivide(double height, double padding, Color color) {
  return Container(
      height: height,
      margin: EdgeInsets.only(
          right: ScreenUtil.instance.setWidth(padding),
          left: ScreenUtil.instance.setWidth(padding)),
      child: Container(
        color: color,
      ));
}

Widget loadingItem() {
  //TODO
  return Center(child: CircularProgressIndicator());
}

Widget netErrorItem() {}

//TODO
