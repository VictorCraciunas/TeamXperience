/// [text] lower-cased with the Romanian diacritics removed, for matching what
/// people type ("brasov" finds "Brașov").
String plainText(String text) => text
    .toLowerCase()
    .replaceAll(RegExp('[ăâ]'), 'a')
    .replaceAll('î', 'i')
    .replaceAll(RegExp('[șş]'), 's')
    .replaceAll(RegExp('[țţ]'), 't');
