/*
 * @author lsy
 * @date   2020-02-11
 **/
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:gengmei_app_face/UserModel/service/local/UserLocal.user.dart';
import 'package:gengmei_app_face/UserModel/service/remote/UserRepo.dart';
import 'package:gengmei_app_face/commonModel/GMBase.dart';
import 'package:gengmei_app_face/commonModel/live/BaseModel.dart';
import 'package:toast/toast.dart';

import 'AnswerItem.dart';

class AnswerModel extends BaseModel {
  LiveData<int> countLive = LiveData();
  LiveData<List<AnswerItem>> contentData = LiveData();
  LiveData<Map<int, String>> questionLive = LiveData();
  int nowPage;
  List<AnswerItem> data = List();
  Map<int, String> questionMap = Map<int, String>();
  EventChannel _eventChannel = EventChannel('answerChannel');
  StreamSubscription _listen;
  String fliterName = "原图";
  int userID;
  String nickName;
  String headUrl;

  init(BuildContext context) {
    UserLocalImpl().getuid().listen((value) {
      print("LSSSSWWWW  ${value}");
      this.userID = value;
    }).onError((error) {
      print(error.toString());
    });
    UserLocalImpl().getnickname().listen((nickName) {
      this.nickName = nickName;
    });
    UserLocalImpl().getheadimgurl().listen((value) {
      this.headUrl = value;
    });
    _listen = _eventChannel
        .receiveBroadcastStream()
        .listen(_onEvent, onError: _onError);
    nowPage = 1;
    UserRepo.getInstance().getAnswerPage(10, nowPage).listen((value) {
      if (value.error == 0) {
        countLive.notifyView(10 * value.count);
        value.comments.forEach((com) {
          data.add(AnswerItem(com.username, com.image, com.content, false, 0,
              "${com.createdTime}", com.filterName));
        });
        contentData.notifyView(data);
      } else {
        Toast.show("出错", context);
      }
    }).onError((error) {
      print(error.toString());
    });
  }

  void _onEvent(Object event) {
    print(event);
    if (event == "closeKeyBoard") {
      closeKeyBoard();
    } else {
      fliterName = event;
    }
  }

  void _onError(Object error) {
    print("ERROR $error");
  }

  void closeKeyBoard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  void dispose() {
    _listen.cancel();
    countLive.dispost();
    contentData.dispost();
  }

  void loadMore(Function(String result) param0) {
    nowPage++;
    UserRepo.getInstance().getAnswerPage(10, nowPage).listen((value) {
      print("${value.error}  ${value.message} ${value.count}");
      if (value.error == 0) {
        if (value.count >= nowPage) {
          value.comments.forEach((com) {
            data.add(AnswerItem(com.username, com.image, com.content, false, 0,
                "${com.createdTime}", com.filterName));
          });
          contentData.notifyView(data);
          param0("success");
        } else {
          param0("notMore");
        }
      } else {
        param0(value.message);
      }
    }).onError((error) {
      param0("接口出错");
      print(error.toString());
    });
  }

  void likeClick(int i) {
    data[i].like = !data[i].like;
    if (data[i].like) {
      data[i].likeCount = data[i].likeCount + 1;
    } else {
      data[i].likeCount = data[i].likeCount - 1;
    }
    contentData.notifyView(data);
  }

  void questionClick(int key, String value) {
    questionMap[key] = value;
    questionLive.notifyView(questionMap);
  }

  void answer(
      BuildContext context, String text, Function(bool success) result) {
    UserRepo.getInstance()
        .submitAnswer("$userID", text, fliterName, questionMap[1],
            questionMap[2], questionMap[3], nickName, headUrl)
        .listen((value) {
      if (value.error == 0) {
        data.insert(
            0, AnswerItem(nickName, headUrl, text, false, 0, "", fliterName));
        Toast.show("评论成功！", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.TOP);
        result(true);
      } else {
        Toast.show("评论失败！", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.TOP);
        result(false);
      }
    }).onError((error) {
      Toast.show("评论失败！", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.TOP);
      result(false);
    });
  }

  void refresh(BuildContext context, Function(String result) param0) {
    this.nowPage = 1;
    data.clear();
    UserRepo.getInstance().getAnswerPage(10, nowPage).listen((value) {
      if (value.error == 0) {
        countLive.notifyView(10 * value.count);
        value.comments.forEach((com) {
          data.add(AnswerItem(com.username, com.image, com.content, false, 0,
              "${com.createdTime}", com.filterName));
        });
        contentData.notifyView(data);
        param0("success");
      } else {
        Toast.show("出错", context);
        param0("${value.message}");
      }
    }).onError((error) {
      print(error.toString());
      param0("${error.message}");
    });
  }
}
