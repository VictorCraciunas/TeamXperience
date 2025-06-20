import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/stire_type.dart';
import '../enums/stire_category.dart';

class Stire {
  String? id;
  String? title;
  String? description;
  DateTime? publicationDate;
  StireType? type;
  StireCategory? category;
  String? buttonText;
  String? buttonLink;
  String? principalImage;
  List<String>? secondaryImages;

  Stire({
    this.id,
    this.title,
    this.description,
    this.publicationDate,
    this.type,
    this.category,
    this.buttonText,
    this.buttonLink,
    this.principalImage,
    this.secondaryImages = const [],
  });

  factory Stire.fromMap(Map<String, dynamic> map) {
    return Stire(
      id: map['id'] as String?,
      title: map['title'] as String?,
      description: map['description'] as String?,
      publicationDate: map['publicationDate'] != null
          ? (map['publicationDate'] as Timestamp).toDate()
          : null,
      type: map['type'] != null
          ? StireType.values.byName(map['type'] as String)
          : null,
      category: map['category'] != null
          ? StireCategory.values.byName(map['category'] as String)
          : null,
      buttonText: map['buttonText'] as String?,
      buttonLink: map['buttonLink'] as String?,
      principalImage: map['principalImage'] as String?,
      secondaryImages: (map['secondaryImages'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'publicationDate': publicationDate,
      'type': type?.name,
      'category': category?.name,
      'buttonText': buttonText,
      'buttonLink': buttonLink,
      'principalImage': principalImage,
      'secondaryImages': secondaryImages,
    };
  }
}