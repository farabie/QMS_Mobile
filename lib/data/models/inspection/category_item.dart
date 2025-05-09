part of '../models.dart';

class CategoryItem {
  final int id;
  final String categoryItem;

  CategoryItem({required this.id, required this.categoryItem});

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id'],
      categoryItem: json['category_item'],
    );
  }
}
