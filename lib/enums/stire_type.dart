enum StireType {
  PUBLICA,
  PRIVATA;

  String get displayName {
    switch (this) {
      case StireType.PUBLICA:
        return 'PUBLICĂ';
      case StireType.PRIVATA:
        return 'PRIVATĂ';
    }
  }
}