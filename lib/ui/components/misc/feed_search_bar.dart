import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';
import 'feed_icon_button.dart';

/// The row at the top of a feed: an optional leading widget (a switch or a
/// create button), a search button that expands into a search field, and a
/// filter button. It is the first item of the scrolling feed, not a pinned bar.
class FeedSearchBar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final colors = context.colors;
    final start = leading;

    return Row(
      children: [
        if (isSearchOpen)
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: colors.iconButtonBg,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      focusNode: searchFocusNode,
                      decoration: InputDecoration(
                        hintText: searchHint,
                        hintStyle: TextStyle(fontSize: 14, color: colors.muted),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(fontSize: 14, color: colors.text),
                    ),
                  ),
                  IconButton(
                    onPressed: onToggleSearch,
                    tooltip: 'Închide căutarea',
                    icon: Icon(Icons.close, size: 22, color: colors.text),
                  ),
                ],
              ),
            ),
          )
        else ...[
          if (start != null) Expanded(child: start) else const Spacer(),
          const SizedBox(width: 8),
          FeedIconButton(
            icon: Icons.search,
            tooltip: 'Caută',
            onTap: onToggleSearch,
          ),
        ],
        const SizedBox(width: 8),
        FeedIconButton(
          icon: filterIcon,
          tooltip: filterLabel,
          onTap: onFilter,
          active: hasActiveFilters,
        ),
      ],
    );
  }
}
