import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/navigation/shell_controller.dart';

void main() {
  test('starts at tab 0', () {
    expect(ShellController(4).index, 0);
  });

  test('select changes the index and notifies', () {
    final controller = ShellController(4);
    var notifications = 0;
    controller.addListener(() => notifications++);
    controller.select(2);
    expect(controller.index, 2);
    expect(notifications, 1);
  });

  test('selecting the current tab does not notify', () {
    final controller = ShellController(4);
    var notifications = 0;
    controller.addListener(() => notifications++);
    controller.select(0);
    expect(notifications, 0);
  });

  test('select ignores out of range indexes', () {
    final controller = ShellController(2);
    controller.select(5);
    controller.select(-1);
    expect(controller.index, 0);
  });

  test('handleBack from another tab goes to tab 0 and consumes the press', () {
    final controller = ShellController(4)..select(2);
    expect(controller.handleBack(), isTrue);
    expect(controller.index, 0);
  });

  test('handleBack at tab 0 is not consumed', () {
    expect(ShellController(4).handleBack(), isFalse);
  });

  test('visited tabs are remembered for lazy building', () {
    final controller = ShellController(3);
    expect(controller.hasVisited(0), isTrue);
    expect(controller.hasVisited(1), isFalse);
    controller.select(1);
    expect(controller.hasVisited(1), isTrue);
    controller.select(0);
    expect(controller.hasVisited(1), isTrue);
  });
}
