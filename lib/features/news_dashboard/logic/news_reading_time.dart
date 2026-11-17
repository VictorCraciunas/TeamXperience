/// How many words a reader gets through in a minute.
const wordsPerMinute = 200;

/// Minutes to read [text]: its words / 200, rounded up, at least 1.
int readingMinutes(String? text) {
  final words = (text ?? '').split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  final minutes = (words / wordsPerMinute).ceil();
  return minutes < 1 ? 1 : minutes;
}

/// "3 min de citit".
String readingTimeText(String? text) => '${readingMinutes(text)} min de citit';
