// lib/core/models/category.dart
import 'package:flutter/material.dart';

class MarketplaceCategory {
  final String title;
  final String itemCount;
  final IconData icon;
  final Color color;

  MarketplaceCategory({
    required this.title,
    required this.itemCount,
    required this.icon,
    required this.color,
  });
}
