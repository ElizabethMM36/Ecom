import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/aura_theme.dart';
import '../product_detail_screen.dart';
import '../../core/models/product.dart';
import '../../widgets/global_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTabIndex = 0;
  int _currentBottomNavIndex = 0;
  // 1. Controller is now correctly defined within the State
  final TextEditingController _searchController = TextEditingController();

  // Color constants to match your Tailwind config
  static const Color surfaceBg = Color(0xFFF7FAF6);
  static const Color onSurface = Color(0xFF191D1A);
  static const Color appBarTitleColor = Color(0xFF004532);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- Helper to Navigate to Details ---
  void _navigateToDetails(
    BuildContext context,
    Map<String, String> productData,
  ) {
    // Create the Demo Product Object using the data from the list
    final demoProduct = Product(
      id: '1',
      name: productData['name'] ?? "Heritage Chronograph 1972",
      location: "Portland, OR",
      condition: productData['condition'] ?? "Like New",
      serialNumber: "SN-8829-X",
      price: double.parse(productData['price'] ?? "0"),
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
        "Location": "Portland, OR",
      },
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: demoProduct),
      ),
    );
  }

  void _handleAction(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceBg,
      appBar: _buildAppBar(),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchSection(),
            const SizedBox(height: 40),
            _buildSectionHeader("Browse Categories"),
            const SizedBox(height: 16),
            _buildCategoriesGrid(),
            const SizedBox(height: 40),
            _buildSectionHeader("Recent Listings", actionLabel: "View Gallery"),
            const SizedBox(height: 24),
            _buildProductList(),
            const SizedBox(height: 100), // Padding for BottomNav
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: surfaceBg,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: appBarTitleColor),
        onPressed: () => print("Open Drawer"),
      ),
      title: Text(
        'The SecondShop',
        style: GoogleFonts.lexend(
          color: appBarTitleColor,
          fontWeight: FontWeight.w900,
          fontSize: 18,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.tune, color: Color(0xFF545F73)),
          onPressed: () => print("Open Filter Dialog"),
        ),
      ],
      shape: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05))),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEE9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.search, color: Colors.grey),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Search curated treasures...",
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 14),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Button is now functional
                print("Searching for: ${_searchController.text}");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AuraTheme.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                "Search",
                style: GoogleFonts.lexend(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? actionLabel}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.lexend(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: onSurface,
          ),
        ),
        if (actionLabel != null)
          TextButton.icon(
            onPressed: () => print("Navigating to $title gallery"),
            icon: const Icon(
              Icons.arrow_forward,
              size: 14,
              color: AuraTheme.primaryGreen,
            ),
            label: Text(
              actionLabel,
              style: GoogleFonts.lexend(
                color: AuraTheme.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoriesGrid() {
    final categories = [
      {'title': 'Electronics', 'icon': Icons.devices, 'count': '1.2k items'},
      {'title': 'Fashion', 'icon': Icons.checkroom, 'count': '3.5k items'},
      {'title': 'Home', 'icon': Icons.chair, 'count': '840 items'},
      {'title': 'Toys', 'icon': Icons.toys, 'count': '520 items'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return InkWell(
          onTap: () => print("Category: ${cat['title']}"),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  cat['icon'] as IconData,
                  color: AuraTheme.primaryGreen,
                  size: 28,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat['title'] as String,
                      style: GoogleFonts.lexend(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      cat['count'] as String,
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductList() {
    final products = [
      {'name': 'Aura Chrono', 'price': '145', 'condition': 'Like New'},
      {'name': 'Velocity Knit', 'price': '89', 'condition': 'New'},
      {'name': 'Sonic Studio', 'price': '210', 'condition': 'Refurbished'},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        return _buildProductCard(products[index]);
      },
    );
  }

  Widget _buildProductCard(Map<String, String> product) {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=1000&auto=format&fit=crop',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.9),
              child: IconButton(
                icon: const Icon(Icons.favorite_border, color: onSurface),
                onPressed: () => print("Liked ${product['name']}"),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name']!,
                      style: GoogleFonts.lexend(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Condition: ${product['condition']}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "\$${product['price']}",
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.bold,
                      color: AuraTheme.primaryGreen,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
