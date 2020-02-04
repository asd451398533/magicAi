/*
 * @author lsy
 * @date   2020-01-17
 **/
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:gengmei_app_face/UserModel/service/local/UserLocal.dart';
import 'package:gengmei_app_face/UserModel/service/local/UserLocal.user.dart';
import 'package:gengmei_app_face/UserModel/service/remote/UserRepo.dart';
import 'package:gengmei_app_face/UserModel/service/remote/entity/WXUserBean.dart';
import 'package:gengmei_app_face/commonModel/GMBase.dart';
import 'package:gengmei_app_face/commonModel/toast/toast.dart';

class UserPageModel extends BaseModel {
  LiveData<WXUserBean> userLive = new LiveData();

  void init(BuildContext context) {
    getAssToken((assToken) {
      if (assToken==null) {
        userLive.notifyView(WXUserBean()..errcode = -1);
      } else {
        getNickName((name) {
          if (name==null) {
            userLive.notifyView(WXUserBean()..errcode = -1);
          } else {
            getHead((head) {
              if (head==null) {
                userLive.notifyView(WXUserBean()..errcode = -1);
              } else {
                userLive.notifyView(WXUserBean()
                  ..headimgurl = head
                  ..nickname = name);
              }
            });
          }
        });
      }
    });
  }

  void getAssToken(Function(String a) func) {
    UserLocalImpl().getrefreshToken().listen((value) {
      func(value);
    });
  }

  void getNickName(Function(String a) func) {
    UserLocalImpl().getnickname().listen((value) {
      func(value);
    });
  }

  void getHead(Function(String a) func) {
    UserLocalImpl().getheadimgurl().listen((value) {
      func(value);
    });
  }

  @override
  void dispose() {
    userLive.dispost();
  }

  void login(BuildContext context) {
    loginWX(WX_APPID).then((value) {
      if (value != null) {
        HashMap<String, Object> map = HashMap<String, Object>.from(value);
        if (map["errcode"] == null ||
            map["errcode"] != 0 ||
            map["code"]==null) {
          userLive.notifyView(WXUserBean()..errcode = 10086);
        } else {
          UserRepo.getInstance().loginWx(map["code"]).listen((loginValue) {
            print("RETURN >>  ${loginValue}");
            if (loginValue.errcode!=null&&loginValue.errcode != 0) {
              userLive.notifyView(WXUserBean()
                ..errcode = loginValue.errcode
                ..errmsg = loginValue.errmsg);
            } else {
              UserRepo.getInstance()
                  .getUserInfo(loginValue.accessToken, loginValue.openid)
                  .listen((value) {
                userLive.notifyView(value);
                if(value.errcode==null||value.errcode==0){
                  Toast.show(context,"登入成功");
                }
              });
            }
          });
        }
      } else {
        userLive.notifyView(WXUserBean()..errcode = 10086);
      }
    });
  }
}
