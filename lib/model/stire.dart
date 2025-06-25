import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/stire_type.dart';
import 'newsCategory.dart';

class Stire {
  String? id;
  String? title;
  String? description;
  DateTime? publicationDate;
  StireType? type;
  NewsCategory? category; // Changed from StireCategory to NewsCategory
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
    // Handle backward compatibility for category field
    NewsCategory? category;
    if (map['category'] != null) {
      if (map['category'] is Map<String, dynamic>) {
        // New format: category is stored as NewsCategory object
        category = NewsCategory.fromMap(map['category'] as Map<String, dynamic>);
      } else if (map['category'] is String) {
        // Old format: category is stored as enum string
        // Create a NewsCategory with the string name and no ID
        category = NewsCategory(name: map['category'] as String);
      }
    }

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
      category: category,
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
      'category': category?.toJson(), // Changed to use NewsCategory's toJson method
      'buttonText': buttonText,
      'buttonLink': buttonLink,
      'principalImage': principalImage,
      'secondaryImages': secondaryImages,
    };
  }
}