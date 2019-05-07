import 'dart:ui';

import 'package:flutter/material.dart';

const appName = 'Flutter paint';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: ThemeData.dark(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _key = GlobalKey<_DrawBodyState>(debugLabel: 'DrawBody');
  final List<Path> _paths = [];
  final List<Path> _undoPaths = [];

  @override
  Widget build(BuildContext context) {
    return DrawData(
      paths: _paths,
      undoPaths: _undoPaths,
      child: Scaffold(
        appBar: _MyAppBar(
          onUndo: _undo,
          onRedo: _redo,
          onClear: _clear,
        ),
        body: _DrawBody(
          key: _key,
          onPath: _onPath,
        ),
      ),
    );
  }

  void _undo() {
    setState(() {
      _undoPaths.add(_paths.removeLast());
    });
  }

  void _redo() {
    setState(() {
      _paths.add(_undoPaths.removeLast());
    });
  }

  void _clear() {
    setState(() {
      _paths.clear();
      _undoPaths.clear();
    });
  }

  void _onPath(Path path) {
    setState(() {
      _paths.add(path);
      _undoPaths.clear();
    });
  }
}

class _MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _MyAppBar({
    Key key,
    @required this.onUndo,
    @required this.onRedo,
    @required this.onClear,
  }) : super(key: key);

  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final DrawData drawData = DrawData.of(context);

    return AppBar(
      title: Text(appName),
      actions: <Widget>[
        IconButton(
          tooltip: 'Undo',
          icon: Icon(Icons.undo),
          onPressed: drawData.paths.isNotEmpty ? onUndo : null,
        ),
        IconButton(
          tooltip: 'Redo',
          icon: Icon(Icons.redo),
          onPressed: drawData.undoPaths.isNotEmpty ? onRedo : null,
        ),
        IconButton(
          tooltip: 'Clear',
          icon: Icon(Icons.delete),
          onPressed: drawData.paths.isNotEmpty || drawData.undoPaths.isNotEmpty
              ? onClear
              : null,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class DrawData extends InheritedWidget {
  final List<Path> paths;
  final List<Path> undoPaths;

  DrawData({
    Key key,
    @required Widget child,
    @required this.paths,
    @required this.undoPaths,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static DrawData of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(DrawData);
  }
}

class _DrawBody extends StatefulWidget {
  const _DrawBody({
    Key key,
    @required this.onPath,
  }) : super(key: key);

  final void Function(Path) onPath;

  @override
  _DrawBodyState createState() => _DrawBodyState();
}

class _DrawBodyState extends State<_DrawBody> {
  final List<Offset> _points = [];
  List<Path> _paths;
  List<Path> _undoPaths;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final DrawData drawData = DrawData.of(context);
    _paths = drawData.paths;
    _undoPaths = drawData.undoPaths;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: _onPanDown,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: CustomPaint(
        painter: _MyPainter(
          paths: _paths,
          points: _points,
        ),
        child: SizedBox.expand(),
      ),
    );
  }

  void _addPoint(Offset globalPosition) {
    final RenderBox renderBox = context.findRenderObject();
    final Offset localPosition = renderBox.globalToLocal(globalPosition);

    setState(() {
      _points.add(localPosition);
    });
  }

  void _onPanDown(DragDownDetails details) {
    _addPoint(details.globalPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _addPoint(details.globalPosition);
  }

  void _onPanEnd(DragEndDetails details) {
    final Path path = _createPathFromPoints();
    widget.onPath(path);
    _points.clear();
  }

  Path _createPathFromPoints() {
    return Path()..addPolygon(_points, false);
  }

  void undo() {
    if (_paths.isNotEmpty) {
      setState(() {
        _undoPaths.add(_paths.removeLast());
      });
    }
  }

  void redo() {
    if (_undoPaths.isNotEmpty) {
      setState(() {
        _paths.add(_undoPaths.removeLast());
      });
    }
  }

  void clear() {
    setState(() {
      _points.clear();
      _paths.clear();
      _undoPaths.clear();
    });
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
