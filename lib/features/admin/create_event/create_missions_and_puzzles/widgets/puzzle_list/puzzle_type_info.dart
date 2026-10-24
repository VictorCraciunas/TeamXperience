import 'package:flutter/material.dart';
import 'package:teamxperience/enums/puzzle_type.dart';

/// How a puzzle type is named and drawn in the builder.
class PuzzleTypeInfo {
  const PuzzleTypeInfo(this.label, this.description, this.icon);

  final String label;
  final String description;
  final IconData icon;

  static const unknown = PuzzleTypeInfo('Fără tip', '', Icons.help_outline);

  static PuzzleTypeInfo of(PuzzleType? type) {
    return switch (type) {
      PuzzleType.code => const PuzzleTypeInfo(
        'Cod',
        'Jucătorii trebuie să introducă un cod',
        Icons.pin_outlined,
      ),
      PuzzleType.imageToUpload => const PuzzleTypeInfo(
        'Fotografie',
        'Trimit o poză, iar tu o aprobi',
        Icons.photo_camera_outlined,
      ),
      PuzzleType.geolocation => const PuzzleTypeInfo(
        'Locație',
        'Trebuie să ajungă într-un loc anume',
        Icons.place_outlined,
      ),
      PuzzleType.redirect => const PuzzleTypeInfo(
        'Link',
        'Îi trimiți către o pagină web',
        Icons.link,
      ),
      PuzzleType.ar => const PuzzleTypeInfo(
        'AR',
        'Realitate augmentată',
        Icons.view_in_ar_outlined,
      ),
      null => unknown,
    };
  }

  /// The types an organiser can pick when adding a puzzle.
  static const choices = [
    PuzzleType.code,
    PuzzleType.imageToUpload,
    PuzzleType.geolocation,
    PuzzleType.redirect,
  ];
}
