/*
 * @author lsy
 * @date   2020-02-11
 **/
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:toast/toast.dart';
import 'package:gengmei_app_face/UserModel/page/answer/AnswerItem.dart';
import 'package:gengmei_app_face/UserModel/page/answer/AnswerModel.dart';
import 'package:gengmei_app_face/commonModel/base/BaseComponent.dart';
import 'package:gengmei_app_face/commonModel/ui/ALColors.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'expanded_viewport.dart';

class AnswerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AnswerPageState();
  }
}

class AnswerPageState extends State<AnswerPage> {
  AnswerModel _model = AnswerModel();
  RefreshController _refreshController = RefreshController();
  ScrollController scrollController = ScrollController();
  TextEditingController editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _model.init(context);
  }

  @override
  void dispose() {
    _model.dispose();
    _refreshController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double keyboardHeight = MediaQuery
        .of(context)
        .viewInsets
        .bottom;
    return Material(
        child: Container(
          color: Colors.black,
          alignment: Alignment.bottomRight,
          width: double.maxFinite,
          height: double.maxFinite,
          child: Column(
            textDirection: TextDirection.ltr,
            children: <Widget>[
              keyboardHeight == 0
                  ? Container(
                alignment: Alignment.center,
                width: double.maxFinite,
                height: 30,
                child: StreamBuilder(
                  stream: _model.countLive.stream,
                  initialData: _model.countLive.data,
                  builder: (c, data) {
                    String showText =
                    data.data == null ? "评论" : "${data.data}条评论";
                    return baseText(showText, 13, ALColors.ColorFFFFFF);
                  },
                ),
              )
                  : Container(height: 30,),
              keyboardHeight == 0
                  ? Expanded(child: refreshView())
                  : Expanded(child: questList()),
//          baseDivide(0.5, 0, ALColors.ColorE5E5E5),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 15, top: 3, bottom: 3),
                      constraints: BoxConstraints(
                        maxHeight: 88,
                        minHeight: 20,
                      ),
                      width: double.maxFinite,
                      child: textField(),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      submit();
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 12, top: 3),
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      child: baseText("发送", 15, ALColors.ColorFFFFFF),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _model.closeKeyBoard();
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 12, right: 15, top: 8),
                      width: 20,
                      height: 20,
                      child: SvgPicture.asset("images/bottom_arrow.svg"),
                    ),
                  )
                ],
              ),
              Container(
                height: keyboardHeight,
              )
            ],
          ),
        ));
  }

  Widget textField() {
    return TextField(
      style: TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: "模拟整形效果如何，谈谈你的使用体验吧～",
        isDense: true,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none),
        filled: true,
        fillColor: ALColors.ColorF7F6FA,
      ),
      maxLines: null,
      enableInteractiveSelection: true,
      autocorrect: false,
      autofocus: false,
      textInputAction:
      Platform.isAndroid ? TextInputAction.newline : TextInputAction.send,
      controller: editingController,
      minLines: null,
      onEditingComplete: () {
        print("COMPLETE");
      },
      onSubmitted: (text) {
        submit();
      },
    );
  }

  void submit() {
    if(_model.userID==null){
      Toast.show("请先返回主页，微信登入后在评论哦！", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.TOP);
      return;
    }
    if(_model.questionMap.length==3){
      if(editingController.text.length!=0){
        _model.answer(context,editingController.text,(result){
          if(result){
            editingController.clear();
            _model.closeKeyBoard();
          }
        });
      }else{
        Toast.show("还没有输入评论哦", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.TOP);
      }
    }else{
      Toast.show("请先回答问题在评论", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.TOP);
    }
  }

  Widget refreshView() {
    return SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        controller: _refreshController,
        onLoading: () async {
          _model.loadMore((message) {
            if (message == "success") {
              _refreshController.loadComplete();
            } else if (message == "notMore") {
              _refreshController.loadNoData();
            } else {
              _refreshController.loadFailed();
            }
          });
        },
        onRefresh: () async{
          _model.refresh(context,(message){
            _refreshController.loadComplete();
            if (message == "success") {
              _refreshController.refreshCompleted();
            } else {
              _refreshController.refreshFailed();
            }
          });
        },
        header: BezierCircleHeader(
          bezierColor:Colors.white,
            circleColor:Colors.blue,
        ),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = baseText("上拉加载", 15, ALColors.ColorFFFFFF);
            } else if (mode == LoadStatus.loading) {
              body = loadingItem();
            } else if (mode == LoadStatus.failed) {
              body = baseText("加载失败！点击重试！", 15, ALColors.ColorFFFFFF);
            } else if (mode == LoadStatus.canLoading) {
              body = baseText("松手,加载更多!", 15, ALColors.ColorFFFFFF);
            } else {
              body = baseText("没有更多数据了!", 15, ALColors.ColorFFFFFF);
            }
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        child: CustomScrollView(
          slivers: <Widget>[
            StreamBuilder<List<AnswerItem>>(
              stream: _model.contentData.stream,
              initialData: _model.data,
              builder: (con, data) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate((c, i) {
                    if (data.data.length == 0) {
                      return Container();
                    }
                    return AnswerItemPage(data.data[i], () {
                      _model.likeClick(i);
                    });
                  }, childCount: data.data.length),
                );
              },
            )
          ],
        ));
  }

  Widget questList() {
    return StreamBuilder(
      stream: _model.questionLive.stream,
      initialData: _model.questionMap,
      builder: (c, data) {
        return ListView(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 2, bottom: 2, left: 15, right: 15),
              child: baseText("你会将这款模拟整形风格作为整形时参考么？", 15, ALColors.ColorFFFFFF),
            ),
            Wrap(
              spacing: 8.0,
              children: <Widget>[
                questionItem(1, "会"),
                questionItem(1, "不会"),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 2, bottom: 2, left: 15, right: 15),
              child: baseText("你认为这款模拟整形风格的效果？", 15, ALColors.ColorFFFFFF),
            ),
            Wrap(
              spacing: 8.0,
              children: <Widget>[
                questionItem(2, "比较好看"),
                questionItem(2, "好看"),
                questionItem(2, "过于难看"),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 2, bottom: 2, left: 15, right: 15),
              child: baseText(
                  "你觉得这款模拟整形风格在以下哪几个布局上做的更差一些？", 15, ALColors.ColorFFFFFF),
            ),
            Wrap(
              spacing: 8.0,
              children: <Widget>[
                questionItem(3, "鼻翼缩小"),
                questionItem(3, "瘦脸"),
                questionItem(3, "眼睛变大"),
                questionItem(3, "嘴唇变厚"),
                questionItem(3, "下巴边尖"),
                questionItem(3, "人中缩短"),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget questionItem(int key, String value) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _model.questionClick(key, value);
      },
      child: Chip(
        backgroundColor:
        _model.questionMap[key] == value ? Colors.pink : Colors.grey,
        label: baseText(value, 15,
            _model.questionMap[key] == value ? Colors.red : Colors.black),
      ),
    );
  }
}
