import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

import 'component_gallery.dart';

/// Run with `flutter run -t lib/dev/gallery_main.dart`. Needs no Firebase.
void main() => runApp(const GalleryApp());

class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key});

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  ThemeMode _mode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    final dark = _mode == ThemeMode.dark;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _mode,
      home: ComponentGallery(
        actions: [
          IconButton(
            tooltip: dark ? 'Luminos' : 'Întunecat',
            icon: Icon(dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => setState(() => _mode = dark ? ThemeMode.light : ThemeMode.dark),
          ),
        ],
      ),
    );
  }
}
