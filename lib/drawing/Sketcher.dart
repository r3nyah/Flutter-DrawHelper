import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'DrawnLine.dart';

class Sketcher extends CustomPainter {
  final ui.Image? background;
  final ui.Image? prevDrawing;
  final List<dynamic> lines;
  final DrawnLine? erase;

  Sketcher({
    this.background,
    this.prevDrawing,
    this.lines = const [],
    this.erase,
  });

  @override
  void paint(Canvas canvas,Size size){
    _addBackground(ui.Image background,{double scale = 1}){
      final width = background.width * scale;
      final height = background.height * scale;
      final left = (size.width - width) / 2;
      final top = (size.height - height) / 2;

      paintImage(
          canvas: canvas,
          rect: Rect.fromLTWH(left, top, width, height),
          fit: BoxFit.scaleDown,
          repeat: ImageRepeat.noRepeat,
          scale: 1,
          alignment: Alignment.center,
          flipHorizontally: false,
          filterQuality: FilterQuality.high,
          image: background
      );
    }
    _addText(DrawnText text){
      final span = TextSpan(style: TextStyle(color: text.color, fontSize: text.size, fontWeight: FontWeight.bold), text: text.text);
      final tp = TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr)..layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      text.offset ??= Offset(
          (size.width - tp.width) / 2,
          (size.height - tp.height) / 2
      );
      tp.paint(canvas, text.offset!);
    }

    if (background != null){
      final scale = min(size.width / background!.width, size.height / background!.height);
      _addBackground(background!,scale: scale);
      canvas.saveLayer(null, Paint());
    }
    if(prevDrawing!=null){
      _addBackground(prevDrawing!);
    }
    Paint paint = Paint()..strokeCap = StrokeCap.round;

    for (int i = 0; i<lines.length;i++){
      final line = lines[i];
      if(line is DrawnLine){
        for(int j = 0;j<line.path.length - 1; ++j){
          if(line.path[j] != null && line.path[j + 1] != null){
            final p1 = line.path[j]!;
            final p2 = line.path[j + 1]!;
            paint.color = line.color;
            paint.strokeWidth = line.width;
            paint.blendMode = line.isEraser ? BlendMode.clear : BlendMode.srcOver;
            canvas.drawLine(p1, p2, paint);
          }
        }
      }else if (line is DrawnText){
        _addText(line);
      }
    }
  }


  @override
  bool shouldRepaint(Sketcher oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}