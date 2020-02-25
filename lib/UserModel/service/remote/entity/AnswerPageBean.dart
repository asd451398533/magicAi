/*
 * @author lsy
 * @date   2020-02-11
 **/
class AnswerPageBean {
  List<Comments> comments;
  int count;
  int error;
  String message;

  AnswerPageBean({this.comments, this.count, this.error, this.message});

  AnswerPageBean.fromJson(Map<String, dynamic> json) {
    if (json['comments'] != null) {
      comments = new List<Comments>();
      json['comments'].forEach((v) {
        comments.add(new Comments.fromJson(v));
      });
    }
    count = json['count'];
    error = json['error'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.comments != null) {
      data['comments'] = this.comments.map((v) => v.toJson()).toList();
    }
    data['count'] = this.count;
    data['error'] = this.error;
    data['message'] = this.message;
    return data;
  }
}

class Comments {
  String content;
  int createdTime;
  String filterName;
  int id;
  String image;
  String question1;
  String question2;
  String question3;
  String question4;
  String question5;
  String question6;
  int updatedTime;
  int userId;
  String username;

  Comments(
      {this.content,
        this.createdTime,
        this.filterName,
        this.id,
        this.image,
        this.question1,
        this.question2,
        this.question3,
        this.question4,
        this.question5,
        this.question6,
        this.updatedTime,
        this.userId,
        this.username});

  Comments.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    createdTime = json['created_time'];
    filterName = json['filter_name'];
    id = json['id'];
    image = json['image'];
    question1 = json['question_1'];
    question2 = json['question_2'];
    question3 = json['question_3'];
    question4 = json['question_4'];
    question5 = json['question_5'];
    question6 = json['question_6'];
    updatedTime = json['updated_time'];
    userId = json['user_id'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['content'] = this.content;
    data['created_time'] = this.createdTime;
    data['filter_name'] = this.filterName;
    data['id'] = this.id;
    data['image'] = this.image;
    data['question_1'] = this.question1;
    data['question_2'] = this.question2;
    data['question_3'] = this.question3;
    data['question_4'] = this.question4;
    data['question_5'] = this.question5;
    data['question_6'] = this.question6;
    data['updated_time'] = this.updatedTime;
    data['user_id'] = this.userId;
    data['username'] = this.username;
    return data;
  }
}
