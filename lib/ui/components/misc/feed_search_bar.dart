import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';
import 'custom_icon_dashboard.dart';

/// The row above a feed: an optional leading widget, a filter button and a
/// search button that expands into a search field.
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
    this.leading,
  });

  final bool isSearchOpen;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final String searchHint;
  final bool hasActiveFilters;
  final VoidCallback onToggleSearch;
  final VoidCallback onFilter;

  /// Shown at the start while the search is closed (for example a create button).
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final start = leading;

    return Row(
      children: [
        if (start != null && !isSearchOpen) Expanded(child: start) else if (!isSearchOpen) const Spacer(),
        if (!isSearchOpen) const SizedBox(width: 8),
        CustomIconDashBoard(
          activeFilter: hasActiveFilters,
          onTap: onFilter,
          iconString: 'assets/images/filter.svg',
        ),
        const SizedBox(width: 8),
        if (isSearchOpen)
          Expanded(
            child: Container(
              height: 45,
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
                    icon: Icon(Icons.close, size: 24, color: colors.text),
                  ),
                ],
              ),
            ),
          )
        else
          CustomIconDashBoard(
            activeFilter: false,
            onTap: onToggleSearch,
            iconString: 'assets/images/search.svg',
          ),
      ],
    );
  }
}
