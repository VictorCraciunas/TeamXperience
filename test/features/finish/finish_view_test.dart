import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/finish/widgets/finish_photo_card.dart';
import 'package:teamxperience/features/finish/widgets/finish_view.dart';
import 'package:teamxperience/features/team_photo/logic/team_album.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';
import 'package:teamxperience/ui/theme/event_palette.dart';
import 'package:teamxperience/ui/theme/event_palette_resolver.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

final _neon = resolveEventPalette(
  hints: const StyleHints(
    background: Color(0xFF0A0F0A),
    surface: Color(0xFF111A11),
    ink: Color(0xFFB8FFC8),
    accent: Color(0xFF33FF66),
    glow: Color(0xFF00CC44),
  ),
  app: AppColors.light,
);

Future<List<String>> _pump(
  WidgetTester tester, {
  String? place = '2',
  String? fastest = 'Cea mai rapidă: misiunea 2 (6 min)',
  List<AlbumPhoto> photos = const [AlbumPhoto('a'), AlbumPhoto('b'), AlbumPhoto('c'), AlbumPhoto('d'), AlbumPhoto('e'), AlbumPhoto('f')],
  Widget? photoCard,
  int? rating,
  EventPalette palette = EventPalette.parchment,
  double width = 316,
  double textScale = 1,
}) async {
  final calls = <String>[];
  tester.view.physicalSize = Size(width * 2, 700 * 2);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child ?? const SizedBox.shrink(),
    ),
    home: Scaffold(
      body: EventThemeScope(
        palette: palette,
        child: FinishView(
          title: 'Harta e completă',
          message: 'Vulpile au moștenit secretul cartografului.',
          place: place,
          placeLabel: 'din 12 echipe',
          time: '1:48',
          km: '4,7',
          missions: 6,
          solved: 6,
          fastest: fastest,
          hints: '2 indicii',
          photos: photos,
          photoCard: photoCard,
          rating: rating,
          onRate: (stars) => calls.add('rate $stars'),
          onShare: () => calls.add('share'),
          onLeaderboard: () => calls.add('board'),
        ),
      ),
    ),
  ));
  return calls;
}

void main() {
  testWidgets('the mockup\'s recap', (tester) async {
    await _pump(tester);
    for (final text in [
      'Harta e completă',
      'Vulpile au moștenit secretul cartografului.',
      '2',
      'din 12 echipe',
      '1:48',
      'timp total',
      '4,7',
      'km pe jos',
      'Cea mai rapidă: misiunea 2 (6 min)',
      '2 indicii',
      'Pozele voastre',
      '+4',
      'Cum ți s-a părut?',
      'Distribuie',
      'Vezi clasamentul',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.byIcon(TablerIcons.star), findsNWidgets(5));
  });

  testWidgets('one dot per mission, the solved ones filled', (tester) async {
    await _pump(tester);
    final done = find.byWidgetPredicate((w) {
      final key = w.key;
      return key is ValueKey<String> && key.value.startsWith('mission-dot-done-');
    });
    expect(done, findsNWidgets(6));
    expect(find.byIcon(TablerIcons.flag), findsOneWidget);
  });

  testWidgets('rating: a tap rates, and the rating shows with a thank-you', (tester) async {
    final calls = await _pump(tester);
    await tester.tap(find.byIcon(TablerIcons.star).at(3));
    expect(calls, ['rate 4']);
    await _pump(tester, rating: 4);
    expect(find.byIcon(TablerIcons.star_filled), findsNWidgets(4));
    expect(find.byIcon(TablerIcons.star), findsOneWidget);
    expect(find.text('Mulțumim!'), findsOneWidget);
  });

  testWidgets('photos are decoded at tile size, and cached', (tester) async {
    await _pump(tester, photos: const [AlbumPhoto('a', label: 'Start')]);
    final image = tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
    expect(image.memCacheWidth, isNotNull);
    expect(image.memCacheWidth, lessThan(800));
  });

  testWidgets('the strip shows when each photo was taken', (tester) async {
    await _pump(tester, photos: const [AlbumPhoto('a', label: 'Start'), AlbumPhoto('b', label: 'Misiunea 3')]);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Misiunea 3'), findsOneWidget);
  });

  testWidgets('the card offers a final photo, then a retake', (tester) async {
    var taps = 0;
    await _pump(tester, photoCard: FinishPhotoCard(busy: false, onTake: () => taps++));
    expect(find.text('O poză de final?'), findsOneWidget);
    expect(find.text('Opțional. Rămâne la Amintiri.'), findsOneWidget);
    await tester.tap(find.text('Fă poza'));
    expect(taps, 1);

    await _pump(tester, photoCard: FinishPhotoCard(photoUrl: 'a', busy: false, onTake: () {}));
    expect(find.text('Poza de final'), findsOneWidget);
    expect(find.text('Refă poza'), findsOneWidget);
  });

  testWidgets('fits 320 px at 1.3x text with the card and long labels', (tester) async {
    await _pump(
      tester,
      width: 320,
      textScale: 1.3,
      photos: const [AlbumPhoto('a', label: 'Start'), AlbumPhoto('b', label: 'Misiunea 12'), AlbumPhoto('c', label: 'Misiunea 13')],
      photoCard: FinishPhotoCard(error: 'Poza nu s-a trimis. Încearcă din nou.', busy: false, onTake: () {}),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('no photos, no fastest mission, no place yet', (tester) async {
    await _pump(tester, photos: const [], fastest: null, place: null);
    expect(find.text('Pozele voastre'), findsNothing);
    expect(find.textContaining('Cea mai rapidă'), findsNothing);
    expect(find.text('2 indicii'), findsOneWidget);
    expect(find.text('–'), findsOneWidget);
  });

  testWidgets('three photos or fewer: no "+N"', (tester) async {
    await _pump(tester, photos: const [AlbumPhoto('a'), AlbumPhoto('b'), AlbumPhoto('c')]);
    expect(find.textContaining('+'), findsNothing);
    expect(find.byKey(const ValueKey('photo-tile')), findsNWidgets(3));
  });

  testWidgets('both buttons', (tester) async {
    final calls = await _pump(tester);
    await tester.tap(find.text('Distribuie'));
    await tester.tap(find.text('Vezi clasamentul'));
    expect(calls, ['share', 'board']);
  });

  testWidgets('another event\'s colours', (tester) async {
    await _pump(tester, palette: _neon);
    expect(tester.widget<Text>(find.text('2')).style?.color, _neon.accent);
  });

  testWidgets('fits 320 px at 1.3x text', (tester) async {
    await _pump(tester, width: 320, textScale: 1.3);
    expect(tester.takeException(), isNull);
  });
}
