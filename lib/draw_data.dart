import 'dart:ui';

import 'package:flutter/foundation.dart';

/// DrawData manages drawing state.
class DrawData extends ChangeNotifier {
  final List<Path> _paths = [];
  int _nextIndex = 0;

  List<Path> get paths => _paths.sublist(0, _nextIndex);
  bool get canUndo => _nextIndex > 0;
  bool get canRedo => _nextIndex < _paths.length;

  void addPath(Path path) {
    if (_nextIndex >= _paths.length) {
      _paths.add(path);
      _nextIndex = _paths.length;
    } else {
      _paths[_nextIndex] = path;
      _nextIndex++;
      _paths.removeRange(_nextIndex, _paths.length);
    }
    notifyListeners();
  }

  void undo() {
    if (_nextIndex > 0) {
      _nextIndex--;
      notifyListeners();
    }
  }

  void redo() {
    if (_nextIndex < _paths.length) {
      _nextIndex++;
      notifyListeners();
    }
  }

  void clear() {
    _paths.clear();
    _nextIndex = 0;
    notifyListeners();
  }
}
