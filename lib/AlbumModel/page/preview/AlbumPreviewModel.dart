/*
 * @author lsy
 * @date   2019-11-01
 **/
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gengmei_app_face/AlbumModel/repository/AlbumRepository.dart';
import 'package:gengmei_app_face/commonModel/GMBase.dart';
import 'package:gengmei_app_face/commonModel/toast/toast.dart';
import 'package:gengmei_flutter_plugin/ScanImagePlugn.dart';
import 'package:gengmei_flutter_plugin/gengmei_flutter_plugin.dart';

class AlbumPreviewModel extends BaseModel {
  AlbumRepository repo = AlbumRepository.getInstance();
  var imageLive = LiveData<String>();
  var pageList = LiveData<List<ScanImageItem>>();
  var titleLive = LiveData<String>();

  var selectLive = LiveData<bool>();
  var nextLive = LiveData<int>();

  final String imgPath;
  int size;
  int _maxCount;
  int maxVideoCount;
  String noVideoHint;
  List<int> cacheList = [];
  Map<int, int> stateMap = Map();

  AlbumPreviewModel(this.imgPath, this.size, this._maxCount, this.maxVideoCount,
      this.noVideoHint);

//
//  Future<Codec> _loadAsync(ResizeFileImage key) async {
//    assert(key == this);
//    final Uint8List bytes = await file.readAsBytes();
//    if (bytes.lengthInBytes == 0) return null;
//    return await instantiateImageCodec(bytes,
//        targetHeight: this.targetHeight, targetWidth: this.targetWidth);
//  }

//  void iosItem(String path, BuildContext context, Function fun) {
//    GengmeiFlutterPlugin.previewImage(path).then((value) {
//      if (value != null) {
//        fun(Map<String, String>.from(value));
//      }
//    }).catchError((error) {
//      Toast.debugShow(context, error.toString());
//      print(error);
//    });
//  }

  @override
  void dispose() {
    cacheList.forEach((index) {
      fromPage[index].data = null;
    });
    cacheList.clear();
    nextLive.dispost();
    selectLive.dispost();
    pageList.dispost();
    imageLive.dispost();
    titleLive.dispost();
  }

  void getRealPath(BuildContext context, int index) {
    if (Platform.isAndroid) {
      return;
    }
    getIosReal(context,index);
    if (index + 1 < fromPage.length) {
      getIosReal(context,index + 1);
    }
    if (index - 1 >= 0) {
      getIosReal(context,index - 1);
    }
//    if (index + 2 < fromPage.length) {
//      getIosReal(index + 2);
//    }
//    if (index - 2 >= 0) {
//      getIosReal(index - 2);
//    }

//    GengmeiFlutterPlugin.ios_album_path([fromPage[index].path]).then((value) {
//      var map = Map<String, String>.from(value[0]);
//      print(map);
//      print("HEEEEEEE  ${map["realImagePath"]}");
//      fromPage[index].realPath = map["realImagePath"];
//      pageList.notifyView(fromPage);
//    }).catchError((error) {
//      Toast.show(context, error.toString());
//      print(error);
//    });
  }

  void getIosReal(BuildContext context,int index) {
    if (fromPage[index].isVideo) {
      return;
    }
    if (stateMap[index] == null || stateMap[index] == 0) {
      stateMap[index] = 1;
      int startTime = DateTime.now().millisecondsSinceEpoch;
      GengmeiFlutterPlugin.getIosImageData(fromPage[index].path).then((value) {
//        if(DateTime.now().millisecondsSinceEpoch-startTime>1500){
//          Toast.show(context,"为您下载iCloud图片" );
//        }
        print("TIME  ${startTime - DateTime.now().millisecondsSinceEpoch}   ${index}");
        if (value == null) {
          print("出错了 晕！ ${fromPage[index].path}");
          stateMap[index] = 0;
          return;
        }
        fromPage[index].data = value;
        cacheList.add(index);
        if (cacheList.length > 12) {
          int removeIndex = cacheList[0];
          fromPage[removeIndex].data = null;
          stateMap[removeIndex] = 0;
          cacheList.removeAt(0);
        }
        pageList.notifyView(fromPage);
      });
    }
  }

  List<ScanImageItem> fromPage;

  void setList(List<ScanImageItem> fromPage) {
    this.fromPage = fromPage;
  }

  void init(BuildContext context) {
    nextLive.notifyView(
        repo.getSelectVideo().length + repo.getSelectPhoto().length);
    pageList.notifyView(fromPage);
  }

  void clickItem(BuildContext context) {
    if (maxVideoCount == 0 && fromPage[currentIndex].isVideo) {
      if (noVideoHint != null) {
        Toast.show(context, noVideoHint);
      }
      return;
    }
    String path;
    if (Platform.isAndroid) {
      path = fromPage[currentIndex].realPath;
    } else {
      path = fromPage[currentIndex].path;
    }
    if (maxVideoCount > 0 && fromPage[currentIndex].isVideo) {
      if (!repo.getSelectVideo().contains(path)) {
        if (repo.getSelectVideo().length >= maxVideoCount) {
          Toast.show(context, "最多选择${maxVideoCount}个视频");
          return;
        }
        repo.addVideo(path);
        selectLive.notifyView(true);
      } else {
        repo.removeVideo(path);
        selectLive.notifyView(false);
      }
    } else {
      if (!repo.getSelectPhoto().contains(path)) {
        if (repo.getSelectPhoto().length >= _maxCount) {
          Toast.show(context, "最多选择${_maxCount}张图片");
          return;
        }
        repo.addPhoto(path);
        selectLive.notifyView(true);
      } else {
        repo.removePhoto(path);
        selectLive.notifyView(false);
      }
    }
    nextLive.notifyView(
        repo.getSelectPhoto().length + repo.getSelectVideo().length);
  }

  int currentIndex;

  void pageIndex(int index) {
    currentIndex = index;
    bool haveIt = false;
    repo.getSelectPhoto().forEach((value) {
      if (Platform.isAndroid) {
        if (value == fromPage[index].realPath) {
          haveIt = true;
        }
      } else {
        if (value == fromPage[index].path) {
          haveIt = true;
        }
      }
    });
    repo.getSelectVideo().forEach((value) {
      if (Platform.isAndroid) {
        if (value == fromPage[index].realPath) {
          haveIt = true;
        }
      } else {
        if (value == fromPage[index].path) {
          haveIt = true;
        }
      }
    });
    selectLive.notifyView(haveIt);
    titleLive.notifyView("${currentIndex + 1} / ${fromPage.length}");
  }

  void playVideo() {
    if (fromPage[currentIndex].isVideo) {
      String path = Platform.isAndroid
          ? fromPage[currentIndex].realPath
          : fromPage[currentIndex].path;
      GengmeiFlutterPlugin.playAlbumVideo(path);
    }
  }

  void onNext() {}
}
