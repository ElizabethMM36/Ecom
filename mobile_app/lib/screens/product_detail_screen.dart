import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/models/product.dart';
import '../core/theme/aura_theme.dart';
import 'checkout_screen.dart';

final Product demoProduct = Product(
  id: '1',
  name: "Heritage Chronograph 1972",
  location: "Portland, OR",
  condition: "Like New",
  serialNumber: "SN-8829-X",
  price: 145,
  description:
      "A stunning example of mid-century craftsmanship. This silver-cased timepiece features original movement, hand-stitched Italian leather strap, and a pristine sapphire crystal.",
  images: [
    'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=1000',
    'https://images.unsplash.com/photo-1526170301353-06674a2741d4?q=80&w=1000',
  ],
  seller: Seller(
    name: "Julian Voss",
    rating: 4.8,
    salesCount: 124,
    imageUrl: "https://i.pravatar.cc/150?u=julian",
  ),
  specifications: {
    "Case Material": "Stainless Steel",
    "Strap": "Genuine Leather",
    "Water Resistance": "30m (Splash proof)",
  },
);

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedImageIndex = 0;

  // Custom Colors from your Tailwind Config
  final Color primaryGreen = const Color(0xFF065F46);
  final Color surfaceBg = const Color(0xFFF7FAF6);
  final Color onSurface = const Color(0xFF002018);
  final Color surfaceContainer = const Color(0xFFEBF2EB);

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: surfaceBg,
      appBar: _buildAppBar(product),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildImageGallery(product),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleSection(product),
                  const SizedBox(height: 20),
                  _buildDescriptionSection(product),
                  const SizedBox(height: 20),
                  _buildSellerCard(product.seller),
                  const SizedBox(height: 20),
                  _buildBuyButton(product.price),
                  const SizedBox(height: 20),
                  _buildSpecsSection(product.specifications),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Product product) {
    return AppBar(
      backgroundColor: surfaceBg,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: primaryGreen),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "AURA",
        style: GoogleFonts.lexend(
          fontWeight: FontWeight.w900,
          color: primaryGreen,
          letterSpacing: -1,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            product.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: product.isFavorite ? Colors.red : const Color(0xFF545F73),
          ),
          onPressed: () =>
              setState(() => product.isFavorite = !product.isFavorite),
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Color(0xFF545F73)),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildImageGallery(Product product) {
    return Column(
      children: [
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 4 / 5,
              child: Image.network(
                product.images[_selectedImageIndex],
                fit: BoxFit.cover,
              ),
            ),
            // Condition Badge
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFA7F3E4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  product.condition.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: product.images.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => setState(() => _selectedImageIndex = index),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedImageIndex == index
                          ? primaryGreen
                          : Colors.transparent,
                      width: 2,
                    ),
                    image: DecorationImage(
                      image: NetworkImage(product.images[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection(Product product) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: GoogleFonts.lexend(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                product.location,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  "CONDITION",
                  product.condition,
                  const Color(0xFF006B5D),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoTile(
                  "SERIAL",
                  product.serialNumber,
                  primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(Product product) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "PRODUCT DESCRIPTION",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product.description,
            style: TextStyle(color: Colors.grey[700], height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerCard(Seller seller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(seller.imageUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    Text(
                      " ${seller.rating}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      " (${seller.salesCount} sales)",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(backgroundColor: surfaceContainer),
            child: Text(
              "Message",
              style: TextStyle(
                color: primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyButton(double price) {
    return SizedBox(
      width: double.infinity,
      height: 65,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CheckoutScreen()),
          );
        },
        icon: const Icon(Icons.shopping_bag_outlined),
        label: Text(
          "Buy Now — \$${price.toStringAsFixed(0)}",
          style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildSpecsSection(Map<String, String> specs) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "SPECIFICATIONS",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          ...specs.entries
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.key,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      Text(
                        e.value,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
