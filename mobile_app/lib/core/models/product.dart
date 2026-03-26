// lib/core/models/category.dart
import 'package:flutter/material.dart';

// lib/core/models/product.dart

class Product {
  final String id;
  final String name;
  final String location;
  final String condition;
  final String serialNumber;
  final String description;
  final double price;
  final List<String> images;
  final Seller seller;
  final Map<String, String> specifications;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.location,
    required this.condition,
    required this.serialNumber,
    required this.description,
    required this.price,
    required this.images,
    required this.seller,
    required this.specifications,
    this.isFavorite = false,
  });
}

class Seller {
  final String name;
  final String imageUrl;
  final double rating;
  final int salesCount;

  Seller({
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.salesCount,
  });
}
