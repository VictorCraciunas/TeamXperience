import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/exceptions/events_exceptions.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/controller/add_missions_controller.dart';

void main() {
  test('one problem is shown as it is', () {
    const e = EventNotPublishableException(['Lipsește locația']);
    expect(publishFailureMessage(e), 'Lipsește locația');
  });

  test('up to three problems are listed one per line', () {
    const e = EventNotPublishableException(['A', 'B', 'C']);
    expect(publishFailureMessage(e), 'A\nB\nC');
  });

  test('more than three are cut, with how many are left', () {
    const e = EventNotPublishableException(['A', 'B', 'C', 'D', 'E']);
    expect(publishFailureMessage(e), 'A\nB\nC\nși încă 2');
  });

  test('an empty list still says something', () {
    const e = EventNotPublishableException([]);
    expect(publishFailureMessage(e), isNotEmpty);
  });
}
