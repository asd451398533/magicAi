/*
 * @author lsy
 * @date   2019-12-20
 **/
import 'package:flutter/cupertino.dart';
import 'package:gengmei_app_face/HomeModel/repo/HomeRepo.dart';
import 'package:gengmei_app_face/commonModel/GMBase.dart';
import 'package:gengmei_app_face/commonModel/toast/toast.dart';

class AIModel extends BaseModel {
  LiveData<String> messageLive = new LiveData();
  LiveData<String> wrongLive = new LiveData();
  static String nonText = "无结果";

  @override
  void dispose() {
    messageLive.dispost();
    wrongLive.dispost();
  }

  void getResult(BuildContext context, String url) {
    HomeRepo.getInstance().getImageAi(url).listen((value) {
      print(value);
      if (value != null) {
        StringBuffer stringBuffer = new StringBuffer();
        StringBuffer errorBuffer = new StringBuffer();
        stringBuffer
            .write("                                                        \n");

        stringBuffer.write("=====眼睛部分=======\n");
        double maxScore = 0;
        String result = nonText;
        value.data.eyelidRight.forEach((value) {
          if (value.score > maxScore) {
            maxScore = value.score;
            result = value.type;
          }
        });
        if (result == nonText) {
          errorBuffer.write("右眼眼皮 这项没有识别出来\n");
        }
        stringBuffer.write("右眼眼皮 : ${result} \n");

        double maxScore1 = 0;
        String result1 = nonText;
        value.data.eyelidLeft.forEach((value) {
          if (value.score > maxScore1) {
            maxScore1 = value.score;
            result1 = value.type;
          }
        });
        if (result1 == nonText) {
          errorBuffer.write("左眼眼皮 这项没有识别出来\n");
        }
        stringBuffer.write("左眼眼皮 : ${result1} \n");

        double maxScore2 = 0;
        String result2 = nonText;
        value.data.eyeShapeRight.forEach((value) {
          if (value.score > maxScore2) {
            maxScore2 = value.score;
            result2 = value.type;
          }
        });
        if (result2 == nonText) {
          errorBuffer.write("右眼眼形 这项没有识别出来\n");
        }
        stringBuffer.write("右眼眼形 : ${result2} \n");

        double maxScore3 = 0;
        String result3 = nonText;
        value.data.eyeShapeLeft.forEach((value) {
          if (value.score > maxScore3) {
            maxScore3 = value.score;
            result3 = value.type;
          }
        });
        if (result3 == nonText) {
          errorBuffer.write("左眼眼形 这项没有识别出来\n");
        }
        stringBuffer.write("左眼眼形 : ${result3} \n");

        double maxScore4 = 0;
        String result4 = nonText;
        value.data.eyeDistance.forEach((value) {
          if (value.score > maxScore4) {
            maxScore4 = value.score;
            result4 = value.type;
          }
        });
        if (result4 == nonText) {
          errorBuffer.write("眼距 这项没有识别出来\n");
        }
        stringBuffer.write("眼距 : ${result4} \n");

        double maxScore400 = 0;
        String result400 = nonText;
        value.data.pouch.forEach((value) {
          if (value.score > maxScore400) {
            maxScore400 = value.score;
            result400 = value.type;
          }
        });
        if (result400 == nonText) {
          errorBuffer.write("眼袋 这项没有识别出来\n");
        }
        stringBuffer.write("眼袋 : ${result400} \n");


        if (value.data.eyePrintLeft != null ||
            value.data.eyePrintLeft.isNotEmpty) {
          stringBuffer
              .write("左眼眼纹  ：${value.data.eyePrintLeft[0].type}\n");
        }else{
          errorBuffer.write("左眼眼纹 这项没有识别出来\n");
        }

        if (value.data.eyePrintRight != null ||
            value.data.eyePrintRight.isNotEmpty) {
          stringBuffer
              .write("右眼眼纹  ：${value.data.eyePrintRight[0].type}\n");
        }else{
          errorBuffer.write("右眼眼纹 这项没有识别出来\n");
        }

        if (value.data.eyeEyelidLeft != null ||
            value.data.eyeEyelidLeft.isNotEmpty) {
          stringBuffer
              .write("左眼上睑下垂比例数值  ：${value.data.eyeEyelidLeft[0]}\n");
        }else{
          errorBuffer.write("左眼上睑下垂比例 这项没有识别出来\n");
        }

        if (value.data.eyeEyelidRight != null ||
            value.data.eyeEyelidRight.isNotEmpty) {
          stringBuffer
              .write("右眼上睑下垂比例数值  ：${value.data.eyeEyelidRight[0]}\n");
        }else{
          errorBuffer.write("右眼上睑下垂比例 这项没有识别出来\n");
        }

        if (value.data.swollenBags != null ||
            value.data.swollenBags.isNotEmpty) {
          stringBuffer
              .write("肿眼泡  ：${value.data.swollenBags[0].type}\n");
        }else{
          errorBuffer.write("肿眼泡 这项没有识别出来\n");
        }

        if (value.data.crowsFeetLeft != null ||
            value.data.crowsFeetLeft.isNotEmpty) {
          stringBuffer
              .write("左眼鱼尾纹  ：${value.data.crowsFeetLeft[0].type}\n");
        }else{
          errorBuffer.write("左眼鱼尾纹 这项没有识别出来\n");
        }

        if (value.data.crowsFeetRight != null ||
            value.data.crowsFeetRight.isNotEmpty) {
          stringBuffer
              .write("右眼鱼尾纹  ：${value.data.crowsFeetRight[0].type}\n");
        }else{
          errorBuffer.write("右眼鱼尾纹 这项没有识别出来\n");
        }

        if (value.data.eyeAngle != null ||
            value.data.eyeAngle.isNotEmpty) {
          stringBuffer
              .write("外眼角角度数值  ：${value.data.eyeAngle[0]}\n");
        }else{
          errorBuffer.write("外眼角角度 这项没有识别出来\n");
        }

        if (value.data.eyeAngleLeft != null ||
            value.data.eyeAngleLeft.isNotEmpty) {
          stringBuffer
              .write("左眼外眼角角度数值  ：${value.data.eyeAngleLeft[0]}\n");
        }else{
          errorBuffer.write("左眼外眼角角度 这项没有识别出来\n");
        }

        if (value.data.eyeAngleRight != null ||
            value.data.eyeAngleRight.isNotEmpty) {
          stringBuffer
              .write("右眼外眼角角度数值  ：${value.data.eyeAngleRight[0]}\n");
        }else{
          errorBuffer.write("右眼外眼角角度 这项没有识别出来\n");
        }

        if (value.data.leigou != null ||
            value.data.leigou.isNotEmpty) {
          stringBuffer
              .write("泪沟  ：${value.data.leigou[0].type}\n");
        }else{
          errorBuffer.write("泪沟 这项没有识别出来\n");
        }

        if (value.data.heiyanquan != null ||
            value.data.heiyanquan.isNotEmpty) {
          stringBuffer
              .write("黑眼圈  ：${value.data.heiyanquan[0].type}\n");
        }else{
          errorBuffer.write("黑眼圈 这项没有识别出来\n");
        }



        stringBuffer.write("\n");
        stringBuffer.write("=====鼻子部分=======\n");
        double maxScore5 = 0;
        String result5 = nonText;
        value.data.nose.forEach((value) {
          if (value.score > maxScore5) {
            maxScore5 = value.score;
            result5 = value.type;
          }
        });
        if (result5 == nonText) {
          errorBuffer.write("鼻子 这项没有识别出来\n");
        }
        stringBuffer.write("鼻子 : ${result5} \n");
        stringBuffer.write("=====嘴唇部分=======\n");
        double maxScore6 = 0;
        String result6 = nonText;
        value.data.lipThickness.forEach((value) {
          if (value.score > maxScore6) {
            maxScore6 = value.score;
            result6 = value.type;
          }
        });
        if (result6 == nonText) {
          errorBuffer.write("嘴唇厚度 这项没有识别出来\n");
        }
        stringBuffer.write("嘴唇厚度 : ${result6} \n");
        double maxScore7 = 0;
        String result7 = nonText;
        value.data.lipPeak.forEach((value) {
          if (value.score > maxScore7) {
            maxScore7 = value.score;
            result7 = value.type;
          }
        });
        if (result7 == nonText) {
          errorBuffer.write("唇峰 这项没有识别出来\n");
        }
        stringBuffer.write("唇峰 : ${result7} \n");

        double maxScore8 = 0;
        String result8 = nonText;
        value.data.lipShape.forEach((value) {
          if (value.score > maxScore8) {
            maxScore8 = value.score;
            result8 = value.type;
          }
        });
        if (result8 == nonText) {
          errorBuffer.write("嘴唇样式 这项没有识别出来\n");
        }
        stringBuffer.write("嘴唇样式 : ${result8} \n");

        double maxScore9 = 0;
        String result9 = nonText;
        value.data.lipRadian.forEach((value) {
          if (value.score > maxScore9) {
            maxScore9 = value.score;
            result9 = value.type;
          }
        });
        if (result9 == nonText) {
          errorBuffer.write("嘴唇弧度 这项没有识别出来\n");
        }
        stringBuffer.write("嘴唇弧度 : ${result9} \n");

//        double maxScore10 = 0;
//        String result10;
//        value.data.lipRadian.forEach((value) {
//          if (value.score > maxScore10) {
//            maxScore10 = value.score;
//            result10 = value.type;
//          }
//        });
//        stringBuffer.write("嘴唇弧度 : ${result10} \n");
        stringBuffer.write("=====法令纹=======\n");
        double maxScore11 = 0;
        String result11 = nonText;
        value.data.wrink.forEach((value) {
          if (value.score > maxScore11) {
            maxScore11 = value.score;
            result11 = value.type;
          }
        });
        if (result11 == nonText) {
          errorBuffer.write("法令纹 这项没有识别出来\n");
        }
        stringBuffer.write("法令纹 : ${result11} \n");
        stringBuffer.write("=====颧骨=======\n");
        double maxScore12 = 0;
        String result12 = nonText;
        value.data.cheekbone.forEach((value) {
          if (value.score > maxScore12) {
            maxScore12 = value.score;
            result12 = value.type;
          }
        });
        if (result12 == nonText) {
          errorBuffer.write("颧骨 这项没有识别出来\n");
        }
        stringBuffer.write("颧骨 : ${result12} \n");
        stringBuffer.write("=====眉毛部分=======\n");
        double maxScore13 = 0;
        String result13 = nonText;
        value.data.browShape.forEach((value) {
          if (value.score > maxScore13) {
            maxScore13 = value.score;
            result13 = value.type;
          }
        });
        if (result13 == nonText) {
          errorBuffer.write("眉毛形状 这项没有识别出来\n");
        }
        stringBuffer.write("眉毛形状 : ${result13} \n");

        double maxScore15 = 0;
        String result15 = nonText;
        value.data.browDensity.forEach((value) {
          if (value.score > maxScore15) {
            maxScore15 = value.score;
            result15 = value.type;
          }
        });
        if (result15 == nonText) {
          errorBuffer.write("眉毛浓密分布 这项没有识别出来\n");
        }
        stringBuffer.write("眉毛浓密分布	 : ${result15} \n");

        if (value.data.eyebrowConcentration != null ||
            value.data.eyebrowConcentration.isNotEmpty) {
          stringBuffer
              .write("眉毛浓度  ：${value.data.eyebrowConcentration[0].type}\n");
        }else{
          errorBuffer.write("眉毛浓度 这项没有识别出来\n");
        }

        if (value.data.eyebrowRough != null ||
            value.data.eyebrowRough.isNotEmpty) {
          stringBuffer
              .write("眉毛粗细  ：${value.data.eyebrowRough[0].type}\n");
        }else{
          errorBuffer.write("眉毛粗细 这项没有识别出来\n");
        }

        stringBuffer.write("=====下巴部分=======\n");
        double maxScore16 = 0;
        String result16 = nonText;
        value.data.chinShape.forEach((value) {
          if (value.score > maxScore16) {
            maxScore16 = value.score;
            result16 = value.type;
          }
        });
        if (result16 == nonText) {
          errorBuffer.write("下巴 这项没有识别出来\n");
        }
        stringBuffer.write("下巴	 : ${result16} \n");

        if (value.data.chinRefraction != null ||
            value.data.chinRefraction.isNotEmpty) {
          stringBuffer
              .write("下巴后缩  ：${value.data.chinRefraction[0]>1?"下巴后缩":"下巴不后缩"}\n");
        }else{
          errorBuffer.write("下巴后缩 这项没有识别出来\n");
        }

        stringBuffer.write("=====面部=======\n");
        if (value.data.bigFace != null ||
            value.data.bigFace.isNotEmpty) {
          stringBuffer
              .write("大脸  ：${value.data.bigFace[0]>1?"大脸":"小脸"}\n");
        }else{
          errorBuffer.write("大脸 这项没有识别出来\n");
        }

        if (value.data.faceshape != null ||
            value.data.faceshape.isNotEmpty) {
          stringBuffer
              .write("脸型  ：${value.data.faceshape[0].type}\n");
        }else{
          errorBuffer.write("脸型 这项没有识别出来\n");
        }


        if (errorBuffer.toString().isNotEmpty) {
          wrongLive.notifyView(
              "这个角度差一丢丢哦，请重新选着一张照片 \n具体信息:\n${errorBuffer.toString()}");
          messageLive.notifyView("未能识别");
//          messageLive.notifyView(stringBuffer.toString());
        } else {
          messageLive.notifyView(stringBuffer.toString());
        }
      }
    }).onError((error) {
      print(error.toString());
      messageLive.notifyView("未能识别");
      wrongLive.notifyView("这个照片不符合规格");
    });
  }
}
