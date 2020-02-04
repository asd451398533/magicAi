import 'package:flutter/material.dart'
    show TextPainter, TextSpan, TextStyle, TextDirection, Size, Color;
import 'dart:ui' as ui;

Size getTextWidth({String text, double fontsize}) {
  final textPainter = TextPainter(
    textDirection: TextDirection.ltr,
    text: TextSpan(
      text: text,
      style: TextStyle(fontSize: fontsize),
    ),
  );
  textPainter.layout();
  return Size(textPainter.width, textPainter.height);
}

ui.Paragraph getParagraph(
    {String text, double fontsize, Color textColor, Size textSize}) {
  ui.TextStyle ts = ui.TextStyle(color: textColor, fontSize: fontsize);
  ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
    textDirection: TextDirection.ltr,
  ))
    ..pushStyle(ts)
    ..addText(text);
  ui.Paragraph paragraph = paragraphBuilder.build()
    ..layout(ui.ParagraphConstraints(width: textSize.width));
  return paragraph;
}
