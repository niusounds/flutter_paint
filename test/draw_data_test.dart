import 'package:flutter/material.dart';
import 'package:flutter_paint/draw_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DrawData', () {
    DrawData drawData = DrawData();

    // initial state
    expect(drawData.paths, isEmpty);
    expect(drawData.canRedo, isFalse);
    expect(drawData.canUndo, isFalse);

    // add a path
    drawData.addPath(Path());
    expect(drawData.paths.length, 1);
    expect(drawData.canRedo, isFalse);
    expect(drawData.canUndo, isTrue);

    // undo
    drawData.undo();
    expect(drawData.paths.length, 0);
    expect(drawData.canRedo, isTrue);
    expect(drawData.canUndo, isFalse);

    // redo
    drawData.redo();
    expect(drawData.paths.length, 1);
    expect(drawData.canRedo, isFalse);
    expect(drawData.canUndo, isTrue);

    // no more redo entries so length will not be changed.
    drawData.redo();
    expect(drawData.paths.length, 1);
    expect(drawData.canRedo, isFalse);
    expect(drawData.canUndo, isTrue);

    drawData.undo();
    expect(drawData.paths.length, 0);
    expect(drawData.canRedo, isTrue);
    expect(drawData.canUndo, isFalse);

    // no more undo entries so length will not be changed.
    drawData.undo();
    expect(drawData.paths.length, 0);
    expect(drawData.canRedo, isTrue);
    expect(drawData.canUndo, isFalse);
  });

  test('DrawData redo overwrite', () {
    final a = Path();
    final b = Path();
    final c = Path();
    final d = Path();

    DrawData drawData = DrawData();

    // add some paths
    drawData.addPath(a);
    drawData.addPath(b);
    drawData.addPath(c);

    expect(drawData.paths, [a, b, c]);

    // back to first state
    drawData.undo();
    drawData.undo();

    expect(drawData.paths, [a]);
    expect(drawData.canRedo, isTrue);

    // add another path will overwrite existing paths
    drawData.addPath(d);

    expect(drawData.paths, [a, d]);
    expect(drawData.canRedo, isFalse);
  });
}
