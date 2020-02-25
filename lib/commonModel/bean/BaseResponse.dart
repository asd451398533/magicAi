/*
 * @author lsy
 * @date   2020-02-12
 **/
import 'package:flutter_common/Annotations/anno/ServerEntity.dart';

@ServerEntity()
class BaseResponse {
  int error;
  String message;

  BaseResponse({this.error, this.message});

  BaseResponse.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['error'] = this.error;
    data['message'] = this.message;
    return data;
  }
}
