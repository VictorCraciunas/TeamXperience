enum StireCategory {
  news,
  announcement,
  event,
  update,
  alert;

  String get displayName {
    switch (this) {
      case StireCategory.news:
        return 'Știri';
      case StireCategory.announcement:
        return 'Anunțuri';
      case StireCategory.event:
        return 'Evenimente';
      case StireCategory.update:
        return 'Actualizări';
      case StireCategory.alert:
        return 'Alerte';
    }
  }
}