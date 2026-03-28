/*
// In your CreateListingScreen, replace your image picker call with:
final imagePath = await Navigator.push<String>(
  context,
  MaterialPageRoute(
    builder: (_) => ListingCameraScreen(
      expectedCategory: selectedCategory, // e.g. "Phone"
    ),
  ),
);
if (imagePath != null) setState(() => _capturedImagePath = imagePath);
```
*/
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/aura_theme.dart';

class ProductListingPage extends StatelessWidget {
  final String categoryTitle;

  const ProductListingPage({super.key, required this.categoryTitle});

  @override
  Widget build(BuildContext context) {
    // Mock data - in a real app, you'd fetch this from an API using the categoryTitle
    final List<Map<String, String>> categoryProducts = [
      {'name': '$categoryTitle Pro', 'price': '499', 'condition': 'Like New'},
      {'name': 'Vintage $categoryTitle', 'price': '120', 'condition': 'Used'},
      {'name': 'Modern $categoryTitle', 'price': '250', 'condition': 'New'},
      {'name': 'Limited Edition', 'price': '800', 'condition': 'Collectible'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF004532)),
        title: Text(
          categoryTitle,
          style: GoogleFonts.lexend(
            color: const Color(0xFF004532),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: categoryProducts.length,
        itemBuilder: (context, index) {
          final product = categoryProducts[index];
          return _buildProductCard(context, product);
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, String> product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: NetworkImage('https://via.placeholder.com/300'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product['name']!,
          style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          "\$${product['price']}",
          style: GoogleFonts.lexend(
            color: AuraTheme.primaryGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          product['condition']!,
          style: GoogleFonts.lexend(color: Colors.grey, fontSize: 11),
        ),
      ],
    );
  }
}
