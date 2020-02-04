/*
 * @author lsy
 * @date   2019-10-18
 **/
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gengmei_app_face/commonModel/picker/base/DialogRouter.dart';

class BaseCenterPicker extends StatefulWidget {
  BaseCenterPickerState centerState;
  ICenterPicker picker;
  bool cancelOutSide = true;

  setPicker(ICenterPicker picker) {
    this.picker = picker;
  }

  sync() {
    centerState?.setState(() {});
  }

  setCancelOutside(bool cancel) {
    this.cancelOutSide = cancel;
  }

  show(BuildContext context) {
    Navigator.push(context, DialogRouter(this));
  }

  dismiss(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  State<StatefulWidget> createState() {
    centerState = BaseCenterPickerState();
    return centerState;
  }
}

class BaseCenterPickerState extends State<BaseCenterPicker> {
  @override
  Widget build(BuildContext context) {
//    ScreenUtil.instance = ScreenUtil(width: 375, height: 667)..init(context);
    return Container(
      color: Colors.black54,
      width: double.maxFinite,
      height: double.maxFinite,
      child: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              if (widget.cancelOutSide) {
                widget.dismiss(context);
              }
            },
          ),
          Center(
              child: Material(
            color: Colors.transparent,
            child: widget.picker.build(context),
          ))
        ],
      ),
    );
  }
}

abstract class ICenterPicker {
  Widget build(BuildContext context);
}
