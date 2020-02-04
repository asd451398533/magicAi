/*
 * @author lsy
 * @date   2019-10-08
 **/

import 'package:shared_preferences/shared_preferences.dart';

import 'CacheManager.dart';

class ShareCache implements ICache{

  @override
  Future get(String key) async{
    var sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.get(key);
  }

  @override
  void save(String key, value) async{
    var sharedPreferences = await SharedPreferences.getInstance();
    if(value is int){
      sharedPreferences.setInt(key, value);
    }else if(value is String){
      sharedPreferences.setString(key, value);
    }else if(value is double){
      sharedPreferences.setDouble(key, value);
    }else if(value is bool){
      sharedPreferences.setBool(key, value);
    }else if(value is List<String>){
      sharedPreferences.setStringList(key, value);
    }else{
      throw new Exception("unknow data kind to save in sharedPreferences");
    }
  }
}