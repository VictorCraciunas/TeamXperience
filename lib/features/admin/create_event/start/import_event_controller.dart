import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/service/event_service/event_json_import.dart';

/// Behind "Import din JSON": reads the pasted text and saves the event as a
/// draft. What was wrong with the text is kept in [errors] for the screen.
class ImportEventController extends ChangeNotifier {
  ImportEventController({required this.saveDraft});

  /// Saves the event as a draft and returns it as saved (with its id).
  final Future<Event> Function(Event event) saveDraft;

  final textController = TextEditingController();

  List<String> errors = const [];
  bool busy = false;

  /// The saved draft, or null when the text had mistakes or saving failed.
  Future<Event?> import() async {
    busy = true;
    errors = const [];
    notifyListeners();

    try {
      final result = importEventFromJson(textController.text);
      final event = result.event;
      if (event == null) {
        errors = result.errors;
        return null;
      }
      return await saveDraft(event);
    } catch (e) {
      errors = ['Nu s-a putut salva ciorna: $e'];
      return null;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.isEmpty) return;

    textController.text = text;
    errors = const [];
    notifyListeners();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}
