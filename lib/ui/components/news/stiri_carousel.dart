import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/model/stire.dart';
import 'package:teamxperience/ui/components/news/stire_card.dart';

class StiriCarousel extends StatefulWidget {
  final List<Stire> stiri;
  final Function(Stire) onStireTap;
  final bool isAdmin;
  final bool showBadge;


  const StiriCarousel({
    super.key,
    required this.stiri,
    required this.onStireTap,
    this.isAdmin = false,
    required this.showBadge

  });

  @override
  State<StiriCarousel> createState() => _StiriCarouselState();
}

class _StiriCarouselState extends State<StiriCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stiri.isEmpty) {
      return const Center(
        child: Text('No news available'),
      );
    }

    return Column(
      children: [
        // Horizontal scrollable news cards
        SizedBox(
          width: double.infinity,
          height: 220, // Same height as your StireCard
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.stiri.length,
            itemBuilder: (context, index) {
              final stire = widget.stiri[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3.0),
                child: StireCard(
                  stire: stire,
                  onTap: () => widget.onStireTap(stire),
                  isAdmin: widget.isAdmin,
                  showBadge: widget.showBadge,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Dots indicator
        _buildDotsIndicator(),
      ],
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.stiri.length,
            (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: _currentIndex == index ? 34.0 : 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            color: _currentIndex == index
                ? context.colors.navy
                : context.colors.insetBorder,
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ),
    );
  }
}