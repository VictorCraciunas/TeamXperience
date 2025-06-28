enum StireType {
  PUBLICA,
  PRIVATA;

  String get displayName {
    switch (this) {
      case StireType.PUBLICA:
        return 'Publică';
      case StireType.PRIVATA:
        return 'Privată';
    }
  }
}