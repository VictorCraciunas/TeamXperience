import 'package:flutter/foundation.dart';

class ShellController extends ChangeNotifier {
  ShellController(this.tabCount) : _visited = {0};

  final int tabCount;
  final Set<int> _visited;
  int _index = 0;

  int get index => _index;

  bool hasVisited(int tab) => _visited.contains(tab);

  void select(int tab) {
    if (tab < 0 || tab >= tabCount || tab == _index) return;
    _index = tab;
    _visited.add(tab);
    notifyListeners();
  }

  /// Returns true when the back press was used to return to the first tab.
  bool handleBack() {
    if (_index == 0) return false;
    select(0);
    return true;
  }
}
