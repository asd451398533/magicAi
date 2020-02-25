/*
 * @author lsy
 * @date   2020-02-12
 **/
class GMUserBean {
  bool isBase64;
  int statusCode;
  Headers headers;
  String message;
  int id;

  GMUserBean(
      {this.isBase64, this.statusCode, this.headers, this.message, this.id});

  GMUserBean.fromJson(Map<String, dynamic> json) {
    isBase64 = json['isBase64'];
    statusCode = json['statusCode'];
    headers =
    json['headers'] != null ? new Headers.fromJson(json['headers']) : null;
    message = json['message'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isBase64'] = this.isBase64;
    data['statusCode'] = this.statusCode;
    if (this.headers != null) {
      data['headers'] = this.headers.toJson();
    }
    data['message'] = this.message;
    data['id'] = this.id;
    return data;
  }
}

class Headers {
  String contentType;
  String accessControlAllowOrigin;

  Headers({this.contentType, this.accessControlAllowOrigin});

  Headers.fromJson(Map<String, dynamic> json) {
    contentType = json['Content-Type'];
    accessControlAllowOrigin = json['Access-Control-Allow-Origin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Content-Type'] = this.contentType;
    data['Access-Control-Allow-Origin'] = this.accessControlAllowOrigin;
    return data;
  }
}
