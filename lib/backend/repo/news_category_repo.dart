import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/newsCategory.dart';

class NewsCategoryRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getNewCategoryId() async {
    return _firestore.collection('categories').doc().id;
  }

  Future<void> createCategory(NewsCategory category) async {
    var docRef = _firestore.collection('categories').doc(category.id);
    await docRef.set(category.toJson());
  }

  Future<void> deleteCategory(String id) async {
    await _firestore.collection('categories').doc(id).delete();
  }

  Future<List<NewsCategory>> getAllCategories() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('categories').get();

      List<NewsCategory> categoryList =
          snapshot.docs.map((doc) {
            return NewsCategory.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();

      return categoryList;
    } catch (e, stacktrace) {
      print('Error fetching categories: $e');
      print('Stack trace: $stacktrace');
      throw Exception('Failed to fetch categories');
    }
  }
}
