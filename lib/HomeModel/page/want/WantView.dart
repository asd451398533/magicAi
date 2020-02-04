/*
 * @author lsy
 * @date   2020-01-02
 **/

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:gengmei_app_face/HomeModel/page/want/WantModel.dart';
import 'package:gengmei_app_face/commonModel/bean/LandMarkBean.dart';

class WantView extends CustomPainter {
  Paint ImagePaint = new Paint()..isAntiAlias = true;

  Paint rectPaint = Paint()
    ..isAntiAlias = true
    ..color = Colors.white
    ..style = PaintingStyle.fill;
  BuildContext context;

  Paint pointPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill
    ..color = Colors.blue
    ..strokeWidth = 3;

  Paint rectPoint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill
    ..color = Colors.black54;

  Paint linePaint = Paint()
    ..isAntiAlias = true
    ..color = Colors.blue
    ..strokeWidth = 1;

  Paint ringShadowPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill
    ..color = Color(0x33000000)
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10);

  WantBean wantBean;

  WantView(this.context, this.wantBean) {}

  @override
  void paint(Canvas canvas, Size size) {
    if (wantBean.errorMessage != null && wantBean.errorMessage.isNotEmpty) {
      TextPainter(
          text: TextSpan(
              text: wantBean.errorMessage,
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.w300)),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center)
        ..layout(maxWidth: size.width / 2, minWidth: size.width / 2)
        ..paint(canvas, Offset(size.width / 4, 0));
    } else {
      double scare = wantBean.image.width / size.width;
      Rect srcRect = new Rect.fromLTRB(0, 0, wantBean.image.width.toDouble(),
          wantBean.image.height.toDouble());
      double diffHeight = (size.height - wantBean.image.height / scare) / 2;
      Rect desRect = new Rect.fromLTRB(
          0, diffHeight, size.width, size.height - diffHeight);
      canvas.drawImageRect(wantBean.image, srcRect, desRect, ImagePaint);

      if (wantBean.landMarkBean != null &&
          wantBean.landMarkBean.faces.length == 1 &&
          wantBean.landMarkBean.faces[0].landmark != null &&
          wantBean.wantMap != null &&
          wantBean.wantMap.isNotEmpty) {
        wantBean.wantMap.forEach((key, value) {
          explainText(canvas, scare, diffHeight, key, value);
        });
      }
    }
  }

  int lenght = 35;

  void drawTextRight(Canvas canvas, double x, double y, String value) {
    canvas.drawPoints(ui.PointMode.points, [Offset(x, y)], pointPaint);
    canvas.drawLine(Offset(x, y), Offset(x + 10, y + 10), linePaint);
    canvas.drawLine(
        Offset(x + 10, y + 10), Offset(x + 10 + lenght, y + 10), linePaint);

    canvas.drawRect(Rect.fromLTWH(x + 10 + lenght, y + 5, 50, 15), rectPoint);
    TextPainter(
        text: TextSpan(
            text: value, style: TextStyle(fontSize: 10, color: Colors.white)),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center)
      ..layout(maxWidth: 50, minWidth: 20)
      ..paint(canvas, Offset(x + 10 + lenght + 3, y + 5));
  }

  void drawTextLeft(Canvas canvas, double x, double y, String value) {
    canvas.drawPoints(ui.PointMode.points, [Offset(x, y)], pointPaint);
    canvas.drawLine(Offset(x, y), Offset(x - 10, y + 10), linePaint);
    canvas.drawLine(
        Offset(x - 10, y + 10), Offset(x - 10 - lenght, y + 10), linePaint);
    canvas.drawRect(
        Rect.fromLTWH(x - 10 - lenght - 50, y + 5, 50, 15), rectPoint);
    TextPainter(
        text: TextSpan(
            text: value, style: TextStyle(fontSize: 10, color: Colors.white)),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center)
      ..layout(maxWidth: 50, minWidth: 20)
      ..paint(canvas, Offset(x - 10 - lenght - 50, y + 5));
  }

  void explainText(Canvas canvas, double scare, double diffHeight, String key,
      String value) {
    var landmark = wantBean.landMarkBean.faces[0].landmark;
    if (key == "eye_big") {
      double x = landmark.rightEyeBottom.x.toDouble() / scare;
      double y = landmark.rightEyeBottom.y.toDouble() / scare + diffHeight;
      drawTextRight(canvas, x, y, value);
    } else if (key == "eye_open") {
      double x = landmark.leftEyeLeftCorner.x.toDouble() / scare;
      double y = landmark.leftEyeLeftCorner.y.toDouble() / scare + diffHeight;
      drawTextLeft(canvas, x, y, value);
    } else if (key == "chin") {
      double x = landmark.contourChin.x.toDouble() / scare;
      double y = landmark.contourChin.y.toDouble() / scare + diffHeight;
      drawTextRight(canvas, x, y, value);
    } else if (key == "nose") {
      double x = landmark.noseRightContour2.x.toDouble() / scare;
      double y = landmark.noseRightContour2.y.toDouble() / scare + diffHeight;
      drawTextRight(canvas, x, y, value);
    } else if (key == "face") {
      double x = landmark.contourRight8.x.toDouble() / scare;
      double y = landmark.contourRight8.y.toDouble() / scare + diffHeight;
      drawTextRight(canvas, x, y, value);
    } else if (key == "lip") {
      double x = landmark.mouthLowerLipLeftContour2.x.toDouble() / scare;
      double y =
          landmark.mouthLowerLipLeftContour2.y.toDouble() / scare + diffHeight;
      drawTextLeft(canvas, x, y, value);
    } else if (key == "tooth") {
      double x = landmark.mouthLowerLipTop.x.toDouble() / scare;
      double y = landmark.mouthLowerLipTop.y.toDouble() / scare + diffHeight;
      drawTextRight(canvas, x, y, value);
    } else if (key == "wrinkles") {
      double x = landmark.mouthLeftCorner.x.toDouble() / scare;
      double y =
          landmark.mouthLeftCorner.y.toDouble() / scare + diffHeight - 25;
      drawTextLeft(canvas, x, y, value);
    } else if (key == "bound") {
      double x = landmark.leftEyeBottom.x.toDouble() / scare;
      double y = landmark.leftEyeBottom.y.toDouble() / scare + diffHeight + 25;
      drawTextLeft(canvas, x, y, value);
    } else if (key == "temples") {
      double x = landmark.contourRight1.x.toDouble() / scare;
      double y = landmark.contourRight1.y.toDouble() / scare + diffHeight + 15;
      canvas.drawPoints(ui.PointMode.points, [Offset(x, y)], pointPaint);
      canvas.drawLine(Offset(x, y), Offset(x + 10, y - 10), linePaint);
      canvas.drawLine(
          Offset(x + 10, y - 10), Offset(x + 10 + lenght, y - 10), linePaint);

      canvas.drawRect(
          Rect.fromLTWH(x + 10 + lenght, y - 15, 50, 15), rectPoint);
      TextPainter(
          text: TextSpan(
              text: value, style: TextStyle(fontSize: 10, color: Colors.white)),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center)
        ..layout(maxWidth: 50, minWidth: 20)
        ..paint(canvas, Offset(x + 10 + lenght, y - 15));
    } else if (key == "black") {
      double x = landmark.leftEyeTop.x.toDouble() / scare;
      double y = landmark.leftEyeTop.y.toDouble() / scare + diffHeight - 10;
      canvas.drawPoints(ui.PointMode.points, [Offset(x, y)], pointPaint);
      canvas.drawLine(Offset(x, y), Offset(x - 10, y - 10), linePaint);
      canvas.drawLine(
          Offset(x - 10, y - 10), Offset(x - 10 - lenght, y - 10), linePaint);

      canvas.drawRect(
          Rect.fromLTWH(x - 10 - lenght - 50, y - 15, 50, 15), rectPoint);
      TextPainter(
          text: TextSpan(
              text: value, style: TextStyle(fontSize: 10, color: Colors.white)),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center)
        ..layout(maxWidth: 50, minWidth: 20)
        ..paint(canvas, Offset(x - 10 - lenght - 50, y - 15));
    } else if (key == "eye_bag") {
      double x = landmark.rightEyeTop.x.toDouble() / scare;
      double y = landmark.rightEyeTop.y.toDouble() / scare + diffHeight;
      canvas.drawPoints(ui.PointMode.points, [Offset(x, y)], pointPaint);
      canvas.drawLine(Offset(x, y), Offset(x + 10, y - 10), linePaint);
      canvas.drawLine(
          Offset(x + 10, y - 10), Offset(x + 10 + lenght, y - 10), linePaint);

      canvas.drawRect(
          Rect.fromLTWH(x + 10 + lenght, y - 15, 50, 15), rectPoint);
      TextPainter(
          text: TextSpan(
              text: value, style: TextStyle(fontSize: 10, color: Colors.white)),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center)
        ..layout(maxWidth: 50, minWidth: 20)
        ..paint(canvas, Offset(x + 10 + lenght, y - 15));
    } else if (key == "brow") {
      double x = landmark.rightEyebrowUpperLeftQuarter.x.toDouble() / scare;
      double y = landmark.rightEyebrowUpperLeftQuarter.y.toDouble() / scare +
          diffHeight;
      canvas.drawPoints(ui.PointMode.points, [Offset(x, y)], pointPaint);
      canvas.drawLine(Offset(x, y), Offset(x + 10, y - 10), linePaint);
      canvas.drawLine(
          Offset(x + 10, y - 10), Offset(x + 10 + lenght, y - 10), linePaint);

      canvas.drawRect(
          Rect.fromLTWH(x + 10 + lenght, y - 15, 50, 15), rectPoint);
      TextPainter(
          text: TextSpan(
              text: value, style: TextStyle(fontSize: 10, color: Colors.white)),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center)
        ..layout(maxWidth: 50, minWidth: 20)
        ..paint(canvas, Offset(x + 10 + lenght, y - 15));
    } else if (key == "head") {
      double x = landmark.noseBridge1.x.toDouble() / scare;
      double y = landmark.noseBridge1.y.toDouble() / scare + diffHeight - 50;
      canvas.drawPoints(ui.PointMode.points, [Offset(x, y)], pointPaint);
      canvas.drawLine(Offset(x, y), Offset(x + 10, y - 10), linePaint);
      canvas.drawLine(
          Offset(x + 10, y - 10), Offset(x + 10 + lenght, y - 10), linePaint);

      canvas.drawRect(
          Rect.fromLTWH(x + 10 + lenght, y - 15, 50, 15), rectPoint);
      TextPainter(
          text: TextSpan(
              text: value, style: TextStyle(fontSize: 10, color: Colors.white)),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center)
        ..layout(maxWidth: 50, minWidth: 20)
        ..paint(canvas, Offset(x + 10 + lenght, y - 15));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
