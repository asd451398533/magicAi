/*
 * @author lsy
 * @date   2019-09-09
 **/

import 'package:gengmei_flutter_plugin/ScanImagePlugn.dart';
import 'package:gengmei_flutter_plugin/gengmei_flutter_plugin.dart';
import 'package:rxdart/rxdart.dart';

const String MainDir = "IsGengmeiAlbumAllImages";
const String MainDirExplain = "全部相片";

class AlbumRepository {
  AlbumRepository._();

  static AlbumRepository _instance;

  static AlbumRepository getInstance() {
    if (_instance == null) {
      _instance = AlbumRepository._();
    }
    return _instance;
  }

  Map<String, List<ScanImageItem>> _mainValue = Map();
  List<String> _selectList = List();
  List<String> _selectVideoList = List();

  Observable<Map<String, List<ScanImageItem>>> scanPhoneImg() {
    return Observable.fromFuture(GengmeiFlutterPlugin.phoneImages());
  }

  void updataMainValue(Map<String, List<ScanImageItem>> value) {
    _mainValue = value;
  }

  Map<String, List<ScanImageItem>> getMainValue() {
    return _mainValue;
  }

  void updateSelectPhoto(List<String> value) {
    _selectList.clear();
    _selectList.addAll(value);
  }

  void updateSelectVideo(List<String> value) {
    _selectVideoList.clear();
    _selectVideoList.addAll(value);
  }

  List<String> getSelectPhoto() {
    return _selectList;
  }

  List<String> getSelectVideo() {
    return _selectVideoList;
  }

  Observable<Map> nativeCamera(String provider) {
    return Observable.fromFuture(GengmeiFlutterPlugin.nativeCamera(provider));
  }

  Observable<String> aiCamera() {
//    return Observable.fromFuture(GengmeiFlutterPlugin.aiCamera());
  }

  void addItem(ScanImageItem item, String foldName) {
    if (_mainValue != null) {
      var list = _mainValue[foldName];
      if (list == null) {
        _mainValue[foldName] = new List();
        _mainValue[foldName].add(item);
      } else {
        list.insert(0, item);
      }
      _mainValue[MainDir].insert(0, item);
    }
  }

  void addVideo(String path) {
    _selectVideoList.add(path);
  }

  void removeVideo(String path) {
    _selectVideoList.remove(path);
  }

  void addPhoto(String path) {
    _selectList.add(path);
  }

  void removePhoto(String path) {
    _selectList.remove(path);
  }

  void clear() {
    _selectList.clear();
    _selectVideoList.clear();
    _mainValue.clear();
  }
}
