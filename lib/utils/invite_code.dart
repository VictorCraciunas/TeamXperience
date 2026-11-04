/// Upper-case, keeping only A-Z and 0-9.
String normaliseCode(String input) =>
    input.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

/// Three letters then three digits, once normalised.
bool isWellFormedCode(String code) =>
    RegExp(r'^[A-Z]{3}[0-9]{3}$').hasMatch(normaliseCode(code));

/// "VLP482" becomes "VLP-482".
String displayCode(String code) {
  final cut = code.length < 3 ? code.length : 3;
  return '${code.substring(0, cut)}-${code.substring(cut)}';
}
