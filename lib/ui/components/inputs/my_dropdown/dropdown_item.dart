import 'package:flutter/material.dart';

/// Data class for dropdown items
class DropdownItem<T> {
  final T value;
  final String label;

  const DropdownItem({
    required this.value,
    required this.label,
  });
}

/// Extension to easily convert from DropdownMenuItem to DropdownItem
extension DropdownMenuItemExtension<T> on List<DropdownMenuItem<T>> {
  List<DropdownItem<T>> toDropdownItems() {
    return map((menuItem) {
      String label = 'Item';
      if (menuItem.child is Text) {
        label = (menuItem.child as Text).data ?? 'Item';
      }
      return DropdownItem<T>(
        value: menuItem.value as T,
        label: label,
      );
    }).toList();
  }
}