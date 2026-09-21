import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/shared/models/home_models.dart';
import 'package:http/http.dart' as http;

abstract interface class CategoryRepository {
  Future<List<CategoryModel>> fetchCategories();
}

final class ApiCategoryRepository implements CategoryRepository {
  const ApiCategoryRepository({
    this.baseUrl = const String.fromEnvironment(
      'CHEFIFY_API_BASE_URL',
      defaultValue: 'http://localhost:8080/api',
    ),
    this.timeout = const Duration(seconds: 8),
  });

  final String baseUrl;
  final Duration timeout;

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    final normalizedBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    final response = await http
        .get(Uri.parse(normalizedBaseUrl).resolve('Category'))
        .timeout(timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Category API returned ${response.statusCode}.');
    }

    final values = jsonDecode(response.body) as List<dynamic>;
    return values
        .map((value) {
          final json = value as Map<String, dynamic>;
          final id = json['id'] ?? json['Id'];
          final name = (json['name'] ?? json['Name'])?.toString().trim() ?? '';
          if (id == null || name.isEmpty) {
            throw const FormatException('Category response is incomplete.');
          }
          return CategoryModel(
            id: id.toString(),
            title: name,
            description: 'Recipes in $name',
            icon: Icons.restaurant_menu_rounded,
            recipesCount: 0,
          );
        })
        .toList(growable: false);
  }
}
