import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'draw_data.dart';

class PaintCanvas extends StatefulWidget {
  const PaintCanvas({
    Key key,
    this.onPathCreated,
  }) : super(key: key);

  final ValueChanged<Path> onPathCreated;

  @override
  PaintCanvasState createState() => PaintCanvasState();
}

class PaintCanvasState extends State<PaintCanvas> {
  final List<Offset> _inDrawingPoints = [];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: _onPanDown,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Consumer<DrawData>(
        builder: (context, drawData, child) => CustomPaint(
          painter: _MyPainter(
            paths: drawData.paths,
            points: _inDrawingPoints,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  void _addPoint(Offset globalPosition) {
    final RenderBox renderBox = context.findRenderObject();
    final Offset localPosition = renderBox.globalToLocal(globalPosition);

    setState(() {
      _inDrawingPoints.add(localPosition);
    });
  }

  void _onPanDown(DragDownDetails details) {
    _addPoint(details.globalPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _addPoint(details.globalPosition);
  }

  /// Clear in-drawing points and create Path.
  void _onPanEnd(DragEndDetails details) {
    final Path path = _createPathFromPoints();
    widget.onPathCreated?.call(path);
    _inDrawingPoints.clear();
  }

  Path _createPathFromPoints() {
    return Path()..addPolygon(_inDrawingPoints, false);
  }
}

class _MyPainter extends CustomPainter {
  final List<Path> paths;
  final List<Offset> points;
  final Paint _paint = Paint();

  _MyPainter({
    @required this.paths,
    @required this.points,
  }) {
    _paint
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..color = Colors.white;
  }

  @override
  void paint(Canvas canvas, Size size) {
    paths.forEach((path) {
      canvas.drawPath(path, _paint);
    });
    canvas.drawPoints(PointMode.polygon, points, _paint);
  }

  @override
  bool shouldRepaint(_MyPainter old) => true;
}
