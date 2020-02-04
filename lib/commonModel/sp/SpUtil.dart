/*
 * @author lsy
 * @date   2019-09-04
 **/

import 'package:gengmei_flutter_plugin/gengmei_flutter_plugin.dart';

class SpUtil {
  static SpUtil _spUtil;

  SpUtil._() {}

  static SpUtil getInstance() {
    if (_spUtil == null) {
      _spUtil = new SpUtil._();
    }
    return _spUtil;
  }

  Future saveBoolKv(String key, bool value) async {
    return await GengmeiFlutterPlugin.saveBool(key, value);
  }

  Future saveStringKv(String key, String value) async {
    return await GengmeiFlutterPlugin.saveString(key, value);
  }

  Future saveDoubleKv(String key, double value) async {
    return await GengmeiFlutterPlugin.saveDouble(key, value);
  }

  Future<bool> saveIntKv(String key, int value) async {
    return await GengmeiFlutterPlugin.saveInt(key, value);
  }

  Future<String> getStringKv(String key) async {
    return await GengmeiFlutterPlugin.getString(key, null);
  }

  Future<bool> getBoolKv(String key) async {
    return await GengmeiFlutterPlugin.getbool(key, null);
  }

  Future<int> getIntKv(String key) async {
    return await GengmeiFlutterPlugin.getInt(key, null);
  }

  Future<double> getDoubleKv(String key) async {
    return await GengmeiFlutterPlugin.getDouble(key, null);
  }

//  Future<bool> clearKv() async {
//    return await GengmeiFlutterPlugin.clear();
//  }
}
