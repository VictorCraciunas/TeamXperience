import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/inputs/app_text_field.dart';

/// The search field the header's round button opens.
class EventsSearchField extends StatefulWidget {
  const EventsSearchField({super.key, required this.initial, required this.onChanged});

  final String initial;
  final ValueChanged<String> onChanged;

  @override
  State<EventsSearchField> createState() => _EventsSearchFieldState();
}

class _EventsSearchFieldState extends State<EventsSearchField> {
  late final TextEditingController _text = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: AppTextField(
        controller: _text,
        hint: 'Caută după nume sau oraș',
        onChanged: widget.onChanged,
      ),
    );
  }
}
