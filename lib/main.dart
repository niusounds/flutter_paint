import 'package:flutter/material.dart';
import 'package:flutter_paint/draw_data.dart';
import 'package:provider/provider.dart';

import 'paint_canvas.dart';

const appName = 'Flutter paint';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: ThemeData.dark(),
      home: const DrawingPage(),
    );
  }
}

class DrawingPage extends StatelessWidget {
  const DrawingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DrawData(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(appName),
          actions: <Widget>[
            Consumer<DrawData>(
              builder: (context, drawData, child) => IconButton(
                tooltip: 'Undo',
                icon: Icon(Icons.undo),
                onPressed: drawData.canUndo ? drawData.undo : null,
              ),
            ),
            Consumer<DrawData>(
              builder: (context, drawData, child) => IconButton(
                tooltip: 'Redo',
                icon: Icon(Icons.redo),
                onPressed: drawData.canRedo ? drawData.redo : null,
              ),
            ),
            Consumer<DrawData>(
              builder: (context, drawData, child) => IconButton(
                tooltip: 'Clear',
                icon: Icon(Icons.delete),
                onPressed: drawData.paths.isNotEmpty ? drawData.clear : null,
              ),
            ),
          ],
        ),
        body: Consumer<DrawData>(
          builder: (context, drawData, child) {
            return PaintCanvas(
              onPathCreated: drawData.addPath,
            );
          },
        ),
      ),
    );
  }
}
