/*
 * @author lsy
 * @date   2019-12-20
 **/
import 'package:flutter_common/Annotations/anno/ServerEntity.dart';

@ServerEntity()
class GMUploadImgBean {
  String fileUrl;
  String file;

  GMUploadImgBean({this.fileUrl, this.file});

  GMUploadImgBean.fromJson(Map<String, dynamic> json) {
    fileUrl = json['file_url'];
    file = json['file'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['file_url'] = this.fileUrl;
    data['file'] = this.file;
    return data;
  }
}
