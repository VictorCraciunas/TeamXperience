import 'package:flutter/material.dart';
import 'package:teamxperience/model/stire.dart';
import 'package:teamxperience/ui/components/misc/carousel_dots.dart';
import 'package:teamxperience/ui/components/misc/section_header.dart';

import 'news_slide_card.dart';

/// "Știri" on Home: the latest news as cards to swipe through, with the next
/// one peeking in and dots saying where you are. It never moves by itself. A
/// single item fills the width, with nothing to swipe.
class HomeNewsCarousel extends StatefulWidget {
  const HomeNewsCarousel({super.key, required this.items, required this.onOpen, required this.onAll});

  final List<Stire> items;
  final ValueChanged<Stire> onOpen;
  final VoidCallback onAll;

  @override
  State<HomeNewsCarousel> createState() => _HomeNewsCarouselState();
}

class _HomeNewsCarouselState extends State<HomeNewsCarousel> {
  static const double _picture = 140;
  static const double _onlyPicture = 170;

  /// How much of the row one card takes; the rest shows the next one.
  static const double _cardShare = .85;

  // The screen margin is 14: these two together, so the first and the last
  // card both keep it when they come to rest.
  static const double _rowInset = 10;
  static const double _cardInset = 4;

  final PageController _pages = PageController(viewportFraction: _cardShare);
  int _current = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  /// The tallest a card can be: two lines of title and a date, at this phone's
  /// text size.
  double _cardHeight(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return _picture +
        scaler.scale(NewsSlideCard.titleSize) * NewsSlideCard.titleHeight * 2 +
        scaler.scale(NewsSlideCard.dateSize) * NewsSlideCard.dateHeight +
        NewsSlideCard.textPadding;
  }

  Widget _swipe(BuildContext context) {
    final items = widget.items;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: _cardHeight(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _rowInset),
            child: PageView.builder(
              controller: _pages,
              padEnds: false,
              clipBehavior: Clip.none,
              itemCount: items.length,
              onPageChanged: (page) => setState(() => _current = page),
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: _cardInset),
                child: NewsSlideCard(
                  stire: items[i],
                  pictureHeight: _picture,
                  onTap: () => widget.onOpen(items[i]),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(child: CarouselDots(count: items.length, current: _current.clamp(0, items.length - 1))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionHeader(title: 'Știri', link: 'Toate', onLink: widget.onAll, top: 16),
        if (items.length == 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: NewsSlideCard(
              stire: items.first,
              pictureHeight: _onlyPicture,
              onTap: () => widget.onOpen(items.first),
            ),
          )
        else
          _swipe(context),
      ],
    );
  }
}
