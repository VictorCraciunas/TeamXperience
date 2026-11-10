import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/event/date_fact_tile.dart';
import 'package:teamxperience/ui/components/event/fact_row.dart';
import 'package:teamxperience/ui/components/event/fact_tile.dart';

import '../pump_ui.dart';

void main() {
  testWidgets('the date sits in the middle of its tile, like the other facts', (tester) async {
    await pumpUi(
      tester,
      const FactRow(
        date: DateFactTile(day: '30', detail: 'nov · 22:55'),
        facts: [FactTile(icon: Icons.schedule, value: '45 min', label: 'durată')],
      ),
    );
    final tile = tester.getRect(find.byType(DateFactTile));
    final top = tester.getRect(find.text('30')).top - tile.top;
    final bottom = tile.bottom - tester.getRect(find.text('nov · 22:55')).bottom;
    expect((top - bottom).abs(), lessThan(2));
  });
}
