import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gengmei_app_face/UserModel/page/phone/PhonePage.dart';
import 'package:gengmei_app_face/UserModel/page/setting/UserSettingWidget.dart';
import 'package:gengmei_app_face/UserModel/service/remote/entity/WXUserBean.dart';
import 'package:gengmei_app_face/commonModel/GMBase.dart';
import 'package:gengmei_app_face/commonModel/toast/toast.dart';
import 'package:gengmei_app_face/commonModel/ui/ALColors.dart';
import 'package:gengmei_app_face/commonModel/util/JumpUtil.dart';
import 'package:gengmei_app_face/commonModel/util/WindowUtil.dart';

import 'UserPageModel.dart';

class UserPageWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return UserPageWidgetState();
  }
}

class UserPageWidgetState extends State<UserPageWidget> {
  UserPageModel _model = UserPageModel();

  @override
  void initState() {
    super.initState();
    _model.init(context);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: baseAppBar(
          needBack: false,
          title: "MagicAi",
          centerTitle: true,
          backgroundColor: Colors.orange,
          action: <Widget>[
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.settings,
                size: 20,
                color: Colors.black,
              ),
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            StreamBuilder<WXUserBean>(
              stream: _model.userLive.stream,
              initialData: _model.userLive.data,
              builder: (c, data) {
                Widget _head;
                if (data.data != null) {
                  if (data.data.errcode == null || data.data.errcode == 0) {
                    _head = ClipOval(
                      child: Image.network(data.data.headimgurl),
                    );
                  } else {
                    _head = GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        JumpUtil.jumpLeft(context, PhonePage()).then((value){
                          if(value!=null){
                            print(value);
                            _model.login(context,value);
                          }else{
                            Toast.show(context, "请完成手机号填写");
                          }
                        });
                      },
                      child: SvgPicture.asset("images/replace_head.svg"),
                    );
                  }
                }

                return Container(
                  alignment: Alignment.center,
                  height: 100,
                  width: double.maxFinite,
                  margin: EdgeInsets.only(top: 40, bottom: 10),
                  child: Container(
                      width: 100,
                      height: 100,
                      child: data.data == null ? loadingItem() : _head),
                );
              },
            ),
            StreamBuilder<WXUserBean>(
              stream: _model.userLive.stream,
              initialData: _model.userLive.data,
              builder: (c, d) {
                String world = "";
                if (d.data != null) {
                  if (d.data.errcode == null || d.data.errcode == 0) {
                    world = d.data.nickname;
                  } else if (d.data.errcode == -1) {
                    world = "点击头像跳转微信登入";
                  } else {
                    world = "登入失败请重试";
                    if (d.data.errmsg != null) {
                      world += d.data.errmsg;
                    }
                  }
                }
                return Container(
                  width: double.maxFinite,
                  height: 35,
                  alignment: Alignment.center,
                  child: baseText(world, 15, Colors.black),
                );
              },
            ),
            Container(
              width: double.maxFinite,
              height: 65,
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.ac_unit,
                          size: 30,
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 5),
                          child: Text("我喜欢的"),
                        )
                      ],
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: new Column(
                      children: <Widget>[
                        Icon(
                          Icons.error,
                          size: 30,
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 5),
                          child: Text("我关注的"),
                        )
                      ],
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: new Column(
                      children: <Widget>[
                        Icon(
                          Icons.queue_play_next,
                          size: 30,
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 5),
                          child: Text("我的记录"),
                        )
                      ],
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: new Column(
                      children: <Widget>[
                        Icon(
                          Icons.edit,
                          size: 30,
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 5),
                          child: Text("客服帮助"),
                        )
                      ],
                    ),
                    flex: 1,
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(20, 30, 20, 0),
              width: double.maxFinite,
              height: 150,
              child: CachedNetworkImage(
                imageUrl:
                    "http://pic51.nipic.com/file/20141025/8649940_220505558734_2.jpg",
                fit: BoxFit.cover,
              ),
            )
          ],
        ));
  }
}
