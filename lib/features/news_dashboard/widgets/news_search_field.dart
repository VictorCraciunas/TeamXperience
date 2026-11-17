import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/inputs/app_text_field.dart';

/// The search field the round search button opens, over titles and texts.
class NewsSearchField extends StatefulWidget {
  const NewsSearchField({super.key, required this.initial, required this.onChanged});

  final String initial;
  final ValueChanged<String> onChanged;

  @override
  State<NewsSearchField> createState() => _NewsSearchFieldState();
}

class _NewsSearchFieldState extends State<NewsSearchField> {
  late final TextEditingController _text = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: AppTextField(
        controller: _text,
        hint: 'Caută știri...',
        textInputAction: TextInputAction.search,
        onChanged: widget.onChanged,
      ),
    );
  }
}
