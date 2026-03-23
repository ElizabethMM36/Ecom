class ProductModel {
  final String id;
  final String title;
  final double price;
  final String description;
  final String city;
  final double latitude;
  final double longitude;
  final List<String> images;

  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.images,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'],
      title: json['title'],
      price: json['price'].toDouble(),
      description: json['description'],
      city: json['itemLocation']['city'],
      latitude: json['itemLocation']['coordinates'][1],
      longitude: json['itemLocation']['coordinates'][0],
      images: List<String>.from(json['images'] ?? []),
    );
  }
}
