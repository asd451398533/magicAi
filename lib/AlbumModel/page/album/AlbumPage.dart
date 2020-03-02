/*
 * @author lsy
 * @date   2019-09-09
 **/
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gengmei_app_face/AlbumModel/bean/DirBean.dart';
import 'package:gengmei_app_face/AlbumModel/util/AlbumUtil.dart';
import 'package:gengmei_app_face/commonModel/GMBase.dart';
import 'package:gengmei_app_face/res/GMRes.dart';
import 'package:gengmei_flutter_plugin/ScanImagePlugn.dart';

import 'AlbumModel.dart';

class AlbumPage extends StatefulWidget {
  AlbumModel model;

  AlbumPage(
      String provider,
      bool showCamera,
      int maxCount,
      List<String> selectedList,
      int maxVideo,
      List<String> videoSelectPath,
      String noVideoHint,
      bool needAiCamera) {
    model = new AlbumModel(
        provider,
        showCamera,
        maxCount,
        selectedList,
        maxVideo,
        videoSelectPath,
        noVideoHint,
        needAiCamera);
  }

  @override
  State<StatefulWidget> createState() => AlbumState(model);
}

class AlbumState extends State<AlbumPage> with SingleTickerProviderStateMixin {
  final AlbumModel _model;
  ScrollController scrollController = new ScrollController();

  AlbumState(this._model);

  Animation<Offset> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    _model.initScanImages(context);
    controller = new AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    animation =
        new Tween(begin: Offset(0, -1), end: Offset(0, 0)).animate(controller)
          ..addListener(() {
            _model.backAnim(1 - animation.value.dy.abs());
          });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 375.0, height: 667.0)
      ..init(context);
    return WillPopScope(
      child: Scaffold(
          appBar: baseAppBarChangeTitle(
            backClick: () {
              Navigator.pop(context, null);
            },
            centerTitle: true,
            title: GestureDetector(
                onTap: () {
                  _model.changPopState();
                },
                child: StreamBuilder<String>(
                    stream: _model.titleData.stream,
                    initialData: _model.titleData.data,
                    builder: (context, data) {
                      Widget text;
                      if (data.data == null) {
                        text = Text("");
                      } else {
                        String showText;
                        if (data.data.length > 10) {
                          showText = "${data.data.substring(0, 10)}...";
                        } else {
                          showText = data.data;
                        }
                        text = baseText(showText, 18, ALColors.Color323232);
                      }
                      return Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(),
                          ),
                          text,
                          Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.fromLTRB(1, 0, 0, 0),
                            child: Transform(
                              transform: Matrix4.identity()
                                ..rotateZ(!_model.showPop ? 1.6 : 4.7), // 旋转的角度
                              origin: Offset(10, 10), // 旋转的中心点
                              child: Icon(
                                Icons.keyboard_arrow_right,
                                size: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(),
                          ),
                        ],
                      );
                    })),
            action: <Widget>[
              StreamBuilder<int>(
                stream: _model.selectSizeLive.stream,
                initialData: _model.selectSizeLive.data,
                builder: (c, data) {
                  String showText = "下一步";
                  Color color = ALColors.Color8E8E8E;
                  if (data.data != null && data.data != 0) {
                    showText = "$showText(${data.data})";
                    color = ALColors.Color323232;
                  }
                  return Center(
                      child: GestureDetector(
                          onTap: () {
                            print("LSY ${_model.allSelectSize()}");
                            if (_model.allSelectSize() > 0) {
                              _model.onNext(context);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
                            child: baseText(showText, 16, color),
                          )));
                },
              )
            ],
          ),
          body: Stack(
            children: <Widget>[
              mainView(),
              backView(),
              popWindow(),
            ],
          )),
      onWillPop: () {
        Navigator.pop(context);
      },
    );
  }

  backView() {
    return StreamBuilder<Color>(
      stream: _model.backLive.stream,
      initialData: _model.backLive.data,
      builder: (con, data) {
        if (data.data == null) {
          return Container();
        }
        return GestureDetector(
            onTap: () {
              _model.changPopState();
            },
            child: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              color: data.data,
            ));
      },
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    _model.dispose();
    controller.dispose();
    super.dispose();
  }

  mainView() {
    return StreamBuilder<List<ScanImageItem>>(
      stream: _model.albumLive.stream,
      initialData: _model.albumLive.data,
      builder:
          (BuildContext context, AsyncSnapshot<List<ScanImageItem>> imgList) {
        if (imgList.data == null) {
          return Center(child: CircularProgressIndicator());
        }
        if (imgList.data != null && imgList.data.isEmpty) {
          return Center(
            child: Text("没有发现照片哦"),
          );
        }
        return GridView.builder(
          controller: scrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
              childAspectRatio: 1),
          itemCount: _model.showCamera
              ? _model.needAiCamera
                  ? imgList.data.length + 2
                  : imgList.data.length + 1
              : imgList.data.length,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0 && _model.showCamera) {
              return GestureDetector(
                  onTap: () => _model.nativeCamera(context),
                  child: Center(
                    child: SvgPicture.asset("images/camera.svg"),
                  ));
            }
            if (index == 1 && _model.needAiCamera) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _model.aiCam(context),
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.white,
                  width: double.maxFinite,
                  height: double.maxFinite,
                  child: Icon(Icons.camera_enhance),
                ),
              );
            }
            int newIndex = _model.showCamera
                ? _model.needAiCamera ? index - 2 : index - 1
                : index;

            if (imgList.data[newIndex] == null ||
                imgList.data[newIndex].path == null ||
                imgList.data[newIndex].path.isEmpty ||
                imgList.data[newIndex].realPath == null && Platform.isAndroid) {
              return Icon(
                Icons.photo,
                size: 20,
              );
            }
            String during;
            if (_model.isVideo(newIndex)) {
              during = AlbumUtil.getFormatTime(imgList.data[newIndex].during);
            }
            return GestureDetector(
                onTap: () {
                  _model.previewItem(context, newIndex);
                },
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: FileImage(File(imgList.data[newIndex].path)),
                          fit: BoxFit.cover),
                      borderRadius: BorderRadius.all(Radius.circular(3.0))),
                  margin: EdgeInsets.only(left: 1, top: 1, right: 1, bottom: 1),
                  child: Stack(
                    alignment: AlignmentDirectional.topEnd,
                    children: <Widget>[
                      _model.maxVideoCount > 0 && _model.isVideo(newIndex)
                          ? _model.isSelectVideo(newIndex)
                              ? SvgPicture.asset("images/album_sel.svg")
                              : SvgPicture.asset("images/album_not_sel.svg")
                          : _model.isSelect(newIndex)
                              ? SvgPicture.asset("images/album_sel.svg")
                              : SvgPicture.asset("images/album_not_sel.svg"),
                      _model.maxVideoCount == 0 && _model.isVideo(newIndex)
                          ? Container(
                              width: double.maxFinite,
                              height: double.maxFinite,
                              color: ALColors.Color33000000,
                            )
                          : Container(),
                      _model.maxVideoCount > 0 && _model.isVideo(newIndex)
                          ? _model.isFullSelectVideo() &&
                                  !_model.isSelectVideo(newIndex)
                              ? Container(
                                  width: double.maxFinite,
                                  height: double.maxFinite,
                                  color: ALColors.Color33000000,
                                )
                              : Container()
                          : _model.isFullSelect() && !_model.isSelect(newIndex)
                              ? Container(
                                  width: double.maxFinite,
                                  height: double.maxFinite,
                                  color: ALColors.Color33000000,
                                )
                              : Container(),
                      _model.isVideo(newIndex)
                          ? Container(
                              width: double.maxFinite,
                              height: double.maxFinite,
                              alignment: Alignment.bottomRight,
                              padding: EdgeInsets.only(right: 5, bottom: 2),
                              child: baseText(during, 15, ALColors.ColorF8F8F8),
                            )
                          : Container(),
                      GestureDetector(
                        onTap: () => _model.clickItem(context, newIndex),
                        child: Container(
                          width: 40,
                          height: 40,
                          color: Colors.transparent,
                        ),
                      )
                    ],
                  ),
                ));
          },
        );
      },
    );
  }

  popWindow() {
    return StreamBuilder<List<DirBean>>(
        stream: _model.dirLive.stream,
        initialData: _model.dirLive.data,
        builder: (BuildContext context, AsyncSnapshot<List<DirBean>> snapshot) {
          if (snapshot.data == null) {
            return Container();
          }
          if (_model.showPop) {
            controller.forward();
          } else {
            controller.reverse();
          }
          return popWindowList(snapshot);
        });
  }

  popWindowList(AsyncSnapshot<List<DirBean>> snapshot) {
    return SlideTransition(
        position: animation,
        child: Container(
            padding: EdgeInsets.fromLTRB(12, 6, 21, 6),
            color: Colors.white,
            height: 280,
            child: ListView.separated(
                separatorBuilder: (context, index) {
                  return Divider();
                },
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  String showDirName = snapshot.data[index].dirName;
                  if (snapshot.data[index].dirName.length > 10) {
                    showDirName =
                        "${snapshot.data[index].dirName.substring(0, 10)}...";
                  }
                  return GestureDetector(
                    onTap: () => _model.selectDir(index),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 52,
                          height: 52,
                          child: Image.file(
                            snapshot.data[index].pic,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: baseText(
                              "${showDirName} (${snapshot.data[index].picCount})",
                              11,
                              ALColors.Color323232),
                        ),
                        Expanded(
                          child: Text(""),
                        ),
//                        Icon(Icons.chevron_right)
                      ],
                    ),
                  );
                })));
  }
}
