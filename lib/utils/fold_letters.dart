/// Romanian letters as their plain Latin letters (ă, â → a; î → i; ș, ş → s;
/// ț, ţ → t), keeping upper and lower case, so a code written with diacritics
/// can be typed on any keyboard.
String foldLetters(String text) => text
    .replaceAll(RegExp('[ăâ]'), 'a')
    .replaceAll(RegExp('[ĂÂ]'), 'A')
    .replaceAll('î', 'i')
    .replaceAll('Î', 'I')
    .replaceAll(RegExp('[șş]'), 's')
    .replaceAll(RegExp('[ȘŞ]'), 'S')
    .replaceAll(RegExp('[țţ]'), 't')
    .replaceAll(RegExp('[ȚŢ]'), 'T');
