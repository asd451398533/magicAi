/*
 * @author lsy
 * @date   2019-12-20
 **/
import 'package:flutter/cupertino.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  Widget buildItem(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: buildItem(context),
      onWillPop: () {
        Navigator.pop(context);
      },
    );
  }
}
