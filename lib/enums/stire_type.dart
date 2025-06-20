enum StireType {
  public,
  private;

  String get displayName {
    switch (this) {
      case StireType.public:
        return 'Public';
      case StireType.private:
        return 'Privat';
    }
  }
}