import 'package:flutter/material.dart';

import '../../../backend/repo/news_category_repo.dart';
import '../../../model/newsCategory.dart';

class NewsCategoryController {
  final NewsCategoryRepo _categoryRepo = NewsCategoryRepo();
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

  void dispose() {
    searchController.dispose();
    newCategoryController.dispose();
  }
}