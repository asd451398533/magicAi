import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class XHeadView extends CustomPainter {
  Paint ImagePaint = new Paint()..isAntiAlias = true;
  Paint rectPaint = Paint()
    ..isAntiAlias = true
    ..color = Colors.white
    ..style = PaintingStyle.fill;
  BuildContext context;
  ui.Image img;
  ui.Image icon;
  Path path;
  String whatWere;
  bool needSyncOne = false;

  Path shadowPath = Path();
  double screenWidth, screenHeight;
  double marginLR = 10, marginT = 150, rectHeight = 120;
  double circleRadius = 27;
  Paint ringPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill
    ..color = Colors.white;

  Paint ringShadowPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill
    ..color = Color(0x33000000)
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10);

  XHeadView(this.context, this.screenWidth, this.screenHeight, this.img,
      this.icon, this.whatWere) {
    path = new Path();
    path.moveTo(marginLR, marginT);
    path.lineTo(screenWidth - marginLR, marginT - 20);
    path.lineTo(screenWidth - marginLR, marginT + rectHeight);
    path.lineTo(marginLR, marginT + rectHeight);
    path.close();
    shadowPath.addArc(
        Rect.fromLTRB(screenWidth / 4 - circleRadius, 200 - circleRadius,
            screenWidth / 4 + circleRadius, 200 + circleRadius),
        0,
        360);
  }

  get allHeight => marginT + rectHeight;

  @override
  void paint(Canvas canvas, Size size) {
    if (img != null) {
      Rect srcRect =
          new Rect.fromLTRB(0, 0, img.width.toDouble(), img.height.toDouble());
      Rect desRect = new Rect.fromLTRB(0, 0, screenWidth, 200);
      canvas.drawImageRect(img, srcRect, desRect, ImagePaint);
    }
    canvas.drawPath(path, rectPaint);

    if (whatWere != null) {
      TextPainter(
          text: TextSpan(
              text: whatWere,
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.w300)),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center)
        ..layout(maxWidth: screenWidth / 2, minWidth: screenWidth / 2)
        ..paint(canvas, Offset(screenWidth / 4, 200));
    } else {
      ringShadowPaint.color = Color(0x33000000);
      canvas.drawCircle(
          Offset(screenWidth / 4, 200), circleRadius + 10, ringShadowPaint);
      canvas.drawCircle(Offset(screenWidth / 4, 200), circleRadius, ringPaint);
      ringShadowPaint.color = Color(0x33668877);
      canvas.drawCircle(
          Offset(screenWidth / 2, 200), circleRadius + 10, ringShadowPaint);
      canvas.drawCircle(Offset(screenWidth / 2, 200), circleRadius, ringPaint);
      ringShadowPaint.color = Color(0x33773377);
      canvas.drawCircle(
          Offset(screenWidth / 4 * 3, 200), circleRadius + 10, ringShadowPaint);
      canvas.drawCircle(
          Offset(screenWidth / 4 * 3, 200), circleRadius, ringPaint);

      TextPainter(
          text: TextSpan(
              text: "AI聚合接口",
              style: TextStyle(fontSize: 13, color: Colors.black)),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center)
        ..layout(maxWidth: screenWidth / 2, minWidth: screenWidth / 2)
        ..paint(canvas, Offset(0, 200 + circleRadius + 6));

      TextPainter(
          text: TextSpan(
              text: "今日头条选图",
              style: TextStyle(fontSize: 13, color: Colors.black)),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center)
        ..layout(maxWidth: screenWidth / 2, minWidth: screenWidth / 2)
        ..paint(canvas, Offset(screenWidth / 4, 200 + circleRadius + 6));

      TextPainter(
          text: TextSpan(
              text: "今日头条视频", style: TextStyle(fontSize: 13, color: Colors.black)),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center)
        ..layout(maxWidth: screenWidth / 2, minWidth: screenWidth / 2)
        ..paint(canvas, Offset(screenWidth / 2, 200 + circleRadius + 6));
    }


    if (icon != null) {
      canvas.drawImageRect(
          icon,
          Rect.fromLTWH(0, 0, icon.width.toDouble(), icon.height.toDouble()),
          Rect.fromLTWH(screenWidth / 4 - 18, 182, 36, 36),
          ImagePaint);

      canvas.drawImageRect(
          icon,
          Rect.fromLTWH(0, 0, icon.width.toDouble(), icon.height.toDouble()),
          Rect.fromLTWH(screenWidth / 2 - 18, 182, 36, 36),
          ImagePaint);

      canvas.drawImageRect(
          icon,
          Rect.fromLTWH(0, 0, icon.width.toDouble(), icon.height.toDouble()),
          Rect.fromLTWH(screenWidth / 4 * 3 - 18, 182, 36, 36),
          ImagePaint);
    }
    if (icon != null && img != null) {
      needSyncOne = true;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    bool needSync=!(img != null && icon != null && needSyncOne);
    return needSync;
  }

  double downX;
  double downY;
  int downTime;
  int downPos = -1;

  onTapDown(TapDownDetails detail) {
    downX = detail.localPosition.dx;
    downY = detail.localPosition.dy;
    downTime = DateTime.now().millisecondsSinceEpoch;

    if (downX > screenWidth / 4 - circleRadius &&
        downX < screenWidth / 4 + circleRadius &&
        downY > 200 - circleRadius &&
        downY < 200 + circleRadius) {
      downPos = 1;
    } else if (downX > screenWidth / 2 - circleRadius &&
        downX < screenWidth / 2 + circleRadius &&
        downY > 200 - circleRadius &&
        downY < 200 + circleRadius) {
      downPos = 2;
    } else if (downX > screenWidth / 4 * 3 - circleRadius &&
        downX < screenWidth / 4 * 3 + circleRadius &&
        downY > 200 - circleRadius &&
        downY < 200 + circleRadius) {
      downPos = 3;
    } else {
      downPos = -1;
    }
  }

  int onTapUp(TapUpDetails detail) {
    if (DateTime.now().millisecondsSinceEpoch - downTime < 400) {
      return downPos;
    }
  }
}
