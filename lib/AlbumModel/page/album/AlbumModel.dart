/*
 * @author lsy
 * @date   2019-09-09
 **/

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:gengmei_app_face/AlbumModel/bean/DirBean.dart';
import 'package:gengmei_app_face/AlbumModel/page/camera/CameraPage.dart';
import 'package:gengmei_app_face/AlbumModel/page/preview/AlbumPreviewPage.dart';
import 'package:gengmei_app_face/AlbumModel/repository/AlbumRepository.dart';
import 'package:gengmei_app_face/commonModel/GMBase.dart';
import 'package:gengmei_app_face/commonModel/live/BaseModel.dart';
import 'package:gengmei_app_face/commonModel/live/LiveData.dart';
import 'package:gengmei_app_face/commonModel/toast/toast.dart';
import 'package:gengmei_app_face/commonModel/util/JumpUtil.dart';
import 'package:gengmei_app_face/res/GMRes.dart';
import 'package:gengmei_flutter_plugin/ScanImagePlugn.dart';
import 'package:gengmei_flutter_plugin/gengmei_flutter_plugin.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

Map<String, List<ScanImageItem>> paseAlbum(Object event) {
  var map = Map<String, List<dynamic>>.from(event);
  var newMap = Map<String, List<ScanImageItem>>();
  map.forEach((k, v) {
    var list = List<Map>.from(v);
    var scanList = List<ScanImageItem>();
    list.forEach((listMap) {
      var map2 = Map<String, dynamic>.from(listMap);
      ScanImageItem item = new ScanImageItem();
      item.path = map2["path"];
      item.isVideo = map2["isVideo"] == "T" ? true : false;
      item.during = map2["during"] ?? "0";
      item.realPath = map2["realPath"] ?? "";
      item.size = map2["size"] ?? 0;
      item.dataToken =
          map2["dataToken"] == null ? 0 : int.parse(map2["dataToken"]);
      scanList.add(item);
    });
    newMap[k] = scanList;
  });
  if (Platform.isIOS) {
    newMap.forEach((k, eachValue) {
      eachValue.sort((a, b) {
        return b.dataToken - a.dataToken;
      });
    });
  }
  return newMap;
}

class AlbumModel extends BaseModel {
  AlbumRepository repo = AlbumRepository.getInstance();
  LiveData<List<ScanImageItem>> albumLive = LiveData();
  LiveData<int> selectSizeLive = LiveData();
  LiveData<List<DirBean>> dirLive = LiveData();
  LiveData<String> titleData = LiveData();
  LiveData<Color> backLive = LiveData();
  String _nowDirName = MainDir;
  StreamSubscription _listen;
  bool showCamera = true;
  final String provider;
  int _maxCount = 1;

  get nowDirName {
    if (_nowDirName == MainDir) {
      return MainDirExplain;
    } else {
      return _nowDirName;
    }
  }

  bool showPop = false;
  List<DirBean> _dirList = List();
  int maxVideoCount;
  final String noVideoHint;
  final bool needAiCamera;

  AlbumModel(
      this.provider,
      this.showCamera,
      int maxCount,
      List<String> selectedList,
      int maxVideoCount,
      List<String> videoSelectPath,
      this.noVideoHint,
      this.needAiCamera) {
    repo.clear();
    this.maxVideoCount = maxVideoCount;
    this._maxCount = maxCount;
    if (selectedList != null && !selectedList.isEmpty) {
      repo.updateSelectPhoto(selectedList);
    }
    if (videoSelectPath != null && !videoSelectPath.isEmpty) {
      repo.updateSelectVideo(videoSelectPath);
    }
  }

  void _onEvent(Object event) {
    compute(paseAlbum, event).then((value) {
      repo.updataMainValue(value);
      _dirList.clear();
      repo.getMainValue().forEach((k, v) {
        _dirList.add(DirBean(
            k == MainDir ? MainDirExplain : k, v.length, File(v[0].path)));
      });
      albumLive.notifyView(repo.getMainValue()[_nowDirName]);
    });
  }

  void _onError(Object error) {
    print("ERROR $error");
  }

  void initScanImages(BuildContext context) {
    titleData.notifyView(MainDirExplain);
    selectSizeLive.notifyView(
        repo.getSelectPhoto().length + repo.getSelectVideo().length);
    _listen = GengmeiFlutterPlugin.phoneImagesEvent
        .receiveBroadcastStream()
        .listen(_onEvent, onError: _onError);
    AlbumRepository.getInstance().scanPhoneImg().listen((value) {
      if (value != null) {
        repo.updataMainValue(value);
        value.forEach((key, eachValue) {
          if (eachValue != null && !eachValue.isEmpty) {
            if (key == MainDir) {
              if (Platform.isIOS) {
                eachValue.sort((a, b) {
                  if (a.dataToken == 0 && b.dataToken != 0) {
                    return -b.dataToken;
                  } else if (a.dataToken != 0 && b.dataToken == 0) {
                    return -a.dataToken;
                  } else if (a.dataToken == 0 && b.dataToken == 0) {
                    return 0;
                  } else {
                    return b.dataToken - a.dataToken;
                  }
                });
              }
              _dirList.add(DirBean(
                  MainDirExplain, eachValue.length, File(eachValue[0].path)));
              albumLive.notifyView(eachValue);
            } else {
              _dirList
                  .add(DirBean(key, eachValue.length, File(eachValue[0].path)));
            }
          }
        });
      }
    }).onError((error) {
      Toast.show(context, error.toString());
      print(error);
    });
  }

  @override
  void dispose() {
    GengmeiFlutterPlugin.quitPage();
    if (_listen != null) {
      _listen.cancel();
    }
    selectSizeLive.dispost();
    backLive.dispost();
    albumLive.dispost();
    dirLive.dispost();
    titleData.dispost();
  }

  bool isSelect(int index) {
    bool haveIt = false;
    if (repo.getSelectPhoto().isEmpty) {
      return false;
    }
    repo.getSelectPhoto().forEach((value) {
      if (Platform.isAndroid) {
        if (value == albumLive.data[index].realPath) {
          haveIt = true;
        }
      } else {
        if (value == albumLive.data[index].path) {
          haveIt = true;
        }
      }
    });

    return haveIt;
  }

  bool isSelectVideo(int index) {
    bool haveIt = false;
    if (repo.getSelectVideo().isEmpty) {
      return false;
    }
    repo.getSelectVideo().forEach((value) {
      if (Platform.isAndroid) {
        if (value == albumLive.data[index].realPath) {
          haveIt = true;
        }
      } else {
        if (value == albumLive.data[index].path) {
          haveIt = true;
        }
      }
    });
    return haveIt;
  }

  bool isFullSelect() {
    return repo.getSelectPhoto().length == _maxCount;
  }

  bool isFullSelectVideo() {
    return repo.getSelectVideo().length == maxVideoCount;
  }

  bool isVideo(int index) {
    return albumLive.data[index].isVideo;
  }

  void clickItem(BuildContext context, int index) {
    if (maxVideoCount == 0 && albumLive.data[index].isVideo) {
      if (noVideoHint != null) {
        Toast.show(context, noVideoHint);
      }
      return;
    }
    String path;
    if (Platform.isAndroid) {
      path = albumLive.data[index].realPath;
    } else {
      path = albumLive.data[index].path;
    }
    if (maxVideoCount > 0 && albumLive.data[index].isVideo) {
      if (!repo.getSelectVideo().contains(path)) {
        if (repo.getSelectVideo().length >= maxVideoCount) {
          Toast.show(context, "最多选择${maxVideoCount}个视频");
          return;
        }
        repo.addVideo(path);
      } else {
        repo.removeVideo(path);
      }
    } else {
      if (!repo.getSelectPhoto().contains(path)) {
        if (repo.getSelectPhoto().length >= _maxCount) {
          Toast.show(context, "最多选择${_maxCount}张图片");
          return;
        }
        repo.addPhoto(path);
      } else {
        repo.removePhoto(path);
      }
    }
    albumLive.notifyView(albumLive.data);
    selectSizeLive.notifyView(
        repo.getSelectPhoto().length + repo.getSelectVideo().length);
  }

  bool onNextclick = false;

  void onNext(BuildContext context) {
    if (onNextclick) {
      return;
    }
    onNextclick = true;
    if (repo.getSelectPhoto().isEmpty && repo.getSelectVideo().isEmpty) {
      Navigator.pop(context, null);
    } else {
      if (Platform.isAndroid) {
        Navigator.pop(context, repo.getSelectPhoto());
      } else {
        iosAlbum(repo.getSelectPhoto(), context, (value) {
          print(value);
          List<String> resultList = new List();
          resultList.add(Map<String, String>.from(value[0])["realImagePath"]);
          Navigator.pop(context, resultList);
        });
      }
    }
  }

  void iosAlbum(List<String> list, BuildContext context, Function fun) {
    GengmeiFlutterPlugin.ios_album_path(list).then((value) {
      if (value != null) {
        fun(List<Map>.from(value));
      }
    }).catchError((error) {
      print(error);
    });
  }

  int allSelectSize() {
    return repo.getSelectPhoto().length + repo.getSelectVideo().length;
  }

  void nativeCamera(BuildContext context) {
//    Toast.show(context, "还没适配，暂时先体验第二个AI相机吧");
//    return;

    if (repo.getSelectPhoto().length == _maxCount) {
      Toast.show(context, "最多选择${_maxCount}张图片");
      return;
    }
//    AlbumRepository.getInstance().nativeCamera(provider).listen((data) {
    JumpUtil.jumpLeft(context, CameraPage()).then((data) {
      if (data == null) {
        Toast.show(context, "没有拍摄照片");
      } else {
        ScanImageItem item = new ScanImageItem();
//        item.realPath = data["realPath"] as String;
//        item.path = data["path"] as String;
//        item.isVideo = false;
        item.realPath = data[0];
        item.path = data[1];
        item.isVideo = false;
        String foldName = "gengmeiAlbum";
        repo.addItem(item, foldName);
        if (Platform.isAndroid) {
          repo.addPhoto(item.realPath);
        } else {
          repo.addPhoto(item.path);
        }
        bool haveIt = false;
        _dirList.forEach((it) {
          if (it.dirName == foldName) {
            haveIt = true;
            it.picCount++;
          }
        });
        if (!haveIt) {
          _dirList.add(new DirBean(foldName, 1, File(item.path)));
        }
        dirLive.notifyView(_dirList);
        albumLive.notifyView(repo.getMainValue()[_nowDirName]);
        selectSizeLive.notifyView(
            repo.getSelectPhoto().length + repo.getSelectVideo().length);
//        Navigator.pop(context, data);
//        _selectList.add(data);
        //TODO
        File(item.realPath).readAsBytes().then((value){
          ImageGallerySaver.saveImage(value);
        });
      }
    }).catchError((error) {
      Toast.show(context, error);
      print(error);
    });
  }

  void changPopState() {
    if (showPop) {
      showPop = false;
      dirLive.notifyView(_dirList);
    } else {
      showPop = true;
      dirLive.notifyView(_dirList);
    }
    titleData.notifyView(nowDirName);
  }

  void selectDir(int index) {
    String dirName = _dirList[index].dirName;

    titleData.notifyView(dirName);
    if (dirName == MainDirExplain) {
      dirName = MainDir;
    }
    _nowDirName = dirName;
    changPopState();
    showPop = false;
    albumLive.notifyView(repo.getMainValue()[dirName]);
  }

  void previewItem(BuildContext context, int index) {
    String path = Platform.isAndroid
        ? albumLive.data[index].realPath
        : albumLive.data[index].path;
    if (albumLive.data[index].isVideo) {
      GengmeiFlutterPlugin.playAlbumVideo(path);
    } else {
      Navigator.push(
              context,
              CustomRoute(AlbumPreviewPage(
                  path,
                  albumLive.data[index].size,
                  albumLive.data,
                  _maxCount,
                  maxVideoCount,
                  noVideoHint,
                  index)))
          .then((value) {
        if (value != null) {
          if (value == -1) {
            onNext(context);
          }
        }
      }).whenComplete(() {
        albumLive.notifyView(repo.getMainValue()[_nowDirName]);
        selectSizeLive.notifyView(
            repo.getSelectPhoto().length + repo.getSelectVideo().length);
      });
    }
  }

  void backAnim(double dy) {
    if (dy < 0.2) {
      backLive.notifyView(null);
      return;
    }
    backLive.notifyView(Color.fromARGB((dy * 255/2).floor(), 0, 0, 0));
  }

  aiCam(BuildContext context) {
    if (repo.getSelectPhoto().length == _maxCount) {
      Toast.show(context, "最多选择${_maxCount}张图片");
      return;
    }
    aiCamera().then((value) {
      var map = Map<String, String>.from(value);
      String path = map["path"];
      if (path == null) {
        Toast.show(context, "没有选着图片哦");
        return;
      }
      String scare_Path = map["scare_path"];
      ScanImageItem item = new ScanImageItem();
      item.realPath = path;
      item.path = scare_Path;
      item.isVideo = false;
      String foldName = "gengmeiAlbum";
      GengmeiFlutterPlugin.addAlbumItem(
              item.isVideo, item.path, item.realPath, foldName, 0)
          .then((value) {
        repo.addItem(item, foldName);
        if (Platform.isAndroid) {
          repo.addPhoto(item.realPath);
        } else {
          repo.addPhoto(item.path);
        }
        bool haveIt = false;
        _dirList.forEach((it) {
          if (it.dirName == foldName) {
            haveIt = true;
            it.picCount++;
          }
        });
        if (!haveIt) {
          _dirList.add(new DirBean(foldName, 1, File(item.path)));
        }
        dirLive.notifyView(_dirList);
        albumLive.notifyView(repo.getMainValue()[_nowDirName]);
        selectSizeLive.notifyView(
            repo.getSelectPhoto().length + repo.getSelectVideo().length);
      });
    });
  }
}
