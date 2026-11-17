import 'package:flutter/material.dart';

import '../../../backend/repo/news_category_repo.dart';
import '../../../model/newsCategory.dart';
import '../../../model/stire.dart';

/// How deleting a category went.
enum DeleteCategoryStatus { deleted, inUse, failed }

class DeleteCategoryResult {
  const DeleteCategoryResult(this.status, [this.newsCount = 0]);

  final DeleteCategoryStatus status;

  /// How many news use the category when [status] is [DeleteCategoryStatus.inUse].
  final int newsCount;
}

class NewsCategoryController {
  NewsCategoryController({NewsCategoryRepo? categoryRepo}) : _injectedRepo = categoryRepo;

  final NewsCategoryRepo? _injectedRepo;
  late final NewsCategoryRepo _categoryRepo = _injectedRepo ?? NewsCategoryRepo();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController newCategoryController = TextEditingController();

  List<NewsCategory> _allCategories = [];
  List<NewsCategory> _filteredCategories = [];
  NewsCategory? _selectedCategory;

  List<NewsCategory> get filteredCategories => _filteredCategories;
  NewsCategory? get selectedCategory => _selectedCategory;

  Future<void> loadCategories() async {
    try {
      _allCategories = await _categoryRepo.getAllCategories();
      _filteredCategories = List.from(_allCategories);
    } catch (e) {
      print('Error loading categories: $e');
      _allCategories = [];
      _filteredCategories = [];
    }
  }

  void filterCategories(String query) {
    if (query.isEmpty) {
      _filteredCategories = List.from(_allCategories);
    } else {
      _filteredCategories = _allCategories
          .where((category) =>
          category.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void selectCategory(NewsCategory category) {
    _selectedCategory = category;
  }

  bool isCategorySelected(NewsCategory category) {
    return _selectedCategory?.id == category.id;
  }

  Future<bool> addNewCategory(String categoryName) async {
    try {
      // Check if category already exists
      if (_allCategories.any((cat) =>
      cat.name.toLowerCase() == categoryName.toLowerCase())) {
        return false; // Category already exists
      }

      final newCategory = NewsCategory(name: categoryName);
      newCategory.id = await _categoryRepo.getNewCategoryId();

      await _categoryRepo.createCategory(newCategory);

      // Add to local lists
      _allCategories.add(newCategory);
      filterCategories(searchController.text); // Refresh filtered list

      return true;
    } catch (e) {
      print('Error adding category: $e');
      return false;
    }
  }

  /// Deletes [category] unless [news] still use it (those news would bring
  /// it back, so they have to change category first).
  Future<DeleteCategoryResult> deleteCategory(NewsCategory category, Iterable<Stire> news) async {
    final lower = category.name.trim().toLowerCase();
    final using = news.where((s) => (s.category?.name ?? '').trim().toLowerCase() == lower).length;
    if (using > 0) return DeleteCategoryResult(DeleteCategoryStatus.inUse, using);

    final id = category.id;
    if (id == null) return const DeleteCategoryResult(DeleteCategoryStatus.failed);
    try {
      await _categoryRepo.deleteCategory(id);
    } catch (_) {
      return const DeleteCategoryResult(DeleteCategoryStatus.failed);
    }
    _allCategories.removeWhere((c) => c.id == id);
    if (_selectedCategory?.id == id) _selectedCategory = null;
    filterCategories(searchController.text);
    return const DeleteCategoryResult(DeleteCategoryStatus.deleted);
  }

  void dispose() {
    searchController.dispose();
    newCategoryController.dispose();
  }
}