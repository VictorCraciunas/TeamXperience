class NewsCategory {
  String? id;
  String name;

  NewsCategory({
    this.id,
    required this.name,
  });

  factory NewsCategory.fromMap(Map<String, dynamic> map) {
    return NewsCategory(
      id: map['id'] as String?,
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name)';
  }
}