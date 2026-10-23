import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';
import 'feed_icon_button.dart';

/// The row at the top of a feed: an optional leading widget (a switch or a
/// create button), a search button and a filter button. Opening the search
/// grows the round search button into a field that takes the whole row while
/// the leading widget shrinks away; closing plays it backwards. It is the first
/// item of the scrolling feed, not a pinned bar.
class FeedSearchBar extends StatefulWidget {
  const FeedSearchBar({
    super.key,
    required this.isSearchOpen,
    required this.searchController,
    required this.searchFocusNode,
    required this.searchHint,
    required this.hasActiveFilters,
    required this.onToggleSearch,
    required this.onFilter,
    this.filterIcon = Icons.tune,
    this.filterLabel = 'Filtrează',
    this.leading,
  });

  final bool isSearchOpen;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final String searchHint;
  final bool hasActiveFilters;
  final VoidCallback onToggleSearch;
  final VoidCallback onFilter;
  final IconData filterIcon;
  final String filterLabel;

  /// Fills the space before the buttons while the search is closed.
  final Widget? leading;

  @override
  State<FeedSearchBar> createState() => _FeedSearchBarState();
}

class _FeedSearchBarState extends State<FeedSearchBar> {
  static const _button = 48.0;
  static const _gap = 8.0;
  static const _duration = Duration(milliseconds: 320);
  static const _curve = Curves.easeInOutCubic;

  @override
  void didUpdateWidget(FeedSearchBar old) {
    super.didUpdateWidget(old);
    if (old.isSearchOpen == widget.isSearchOpen) return;

    // Focus after the field has started to appear, drop it when closing.
    if (widget.isSearchOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.searchFocusNode.requestFocus();
      });
    } else {
      widget.searchFocusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final open = widget.isSearchOpen;

    return LayoutBuilder(
      builder: (context, constraints) {
        final total = constraints.maxWidth;
        // closed: [leading][gap][search 48][gap][filter 48]
        final openField = total - _button - _gap;
        final leadingClosed = total - _button * 2 - _gap * 2 + _gap;

        return Row(
          children: [
            AnimatedContainer(
              key: const ValueKey('feed-search-leading'),
              duration: _duration,
              curve: _curve,
              width: open ? 0 : leadingClosed,
              height: _button, // bounded, so the OverflowBox below never sees an unbounded height in a list
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.centerLeft,
                  minWidth: 0,
                  maxWidth: leadingClosed,
                  child: AnimatedOpacity(
                    duration: _duration,
                    opacity: open ? 0 : 1,
                    child: IgnorePointer(
                      ignoring: open,
                      child: Padding(
                        padding: const EdgeInsets.only(right: _gap),
                        child: widget.leading ?? const SizedBox(height: _button),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _SearchField(
              open: open,
              width: open ? openField : _button,
              openWidth: openField,
              duration: _duration,
              curve: _curve,
              controller: widget.searchController,
              focusNode: widget.searchFocusNode,
              hint: widget.searchHint,
              onToggle: widget.onToggleSearch,
            ),
            const SizedBox(width: _gap),
            FeedIconButton(
              icon: widget.filterIcon,
              tooltip: widget.filterLabel,
              onTap: widget.onFilter,
              active: widget.hasActiveFilters,
            ),
          ],
        );
      },
    );
  }
}

/// The search button that grows into a field. Its content is laid out at the
/// full open width and clipped by the animating box, so the field is revealed
/// from the left as it grows.
class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.open,
    required this.width,
    required this.openWidth,
    required this.duration,
    required this.curve,
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.onToggle,
  });

  final bool open;
  final double width;
  final double openWidth;
  final Duration duration;
  final Curve curve;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedContainer(
      key: const ValueKey('feed-search-field'),
      duration: duration,
      curve: curve,
      width: width,
      height: 48,
      decoration: BoxDecoration(
        color: colors.panel,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.tick, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: OverflowBox(
          alignment: Alignment.centerLeft,
          minWidth: 0,
          maxWidth: openWidth,
          child: SizedBox(
            width: openWidth,
            child: Row(
              children: [
                IconButton(
                  onPressed: open ? null : onToggle,
                  tooltip: 'Caută',
                  icon: Icon(Icons.search, color: colors.text, size: 22),
                ),
                Expanded(
                  child: AnimatedOpacity(
                    duration: duration,
                    opacity: open ? 1 : 0,
                    child: IgnorePointer(
                      ignoring: !open,
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: hint,
                          hintStyle: TextStyle(fontSize: 14, color: colors.muted),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(fontSize: 14, color: colors.text),
                      ),
                    ),
                  ),
                ),
                AnimatedOpacity(
                  duration: duration,
                  opacity: open ? 1 : 0,
                  child: IgnorePointer(
                    ignoring: !open,
                    child: IconButton(
                      onPressed: onToggle,
                      tooltip: 'Închide căutarea',
                      icon: Icon(Icons.close, size: 22, color: colors.text),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
