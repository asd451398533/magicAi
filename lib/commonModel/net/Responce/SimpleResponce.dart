/*
 * @author lsy
 * @date   2019-09-05
 **/
class SimpleResponce {
  int error;
  String message;
  Null extra;
  Data data;

  SimpleResponce({this.error, this.message, this.extra, this.data});

  SimpleResponce.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    message = json['message'];
    extra = json['extra'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['error'] = this.error;
    data['message'] = this.message;
    data['extra'] = this.extra;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class Data {
  int error;
  String message;

  Data({this.error, this.message});

  Data.fromJson(Map<String, dynamic> json) {
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
