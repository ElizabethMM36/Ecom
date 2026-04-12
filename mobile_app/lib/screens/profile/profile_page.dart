import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/core/theme/aura_theme.dart';
import 'package:mobile_app/screens/auth/login.dart';
import 'package:mobile_app/core/providers/user_provider.dart';
import '../../widgets/global_nav_bar.dart';

class ProfilePage extends StatefulWidget {
  final int selectedIndex;

  const ProfilePage({super.key, this.selectedIndex = 4});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late int _currentBottomNavIndex;

  @override
  void initState() {
    super.initState();
    _currentBottomNavIndex = widget.selectedIndex;
  }

  void _handleAction(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Logout",
            style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to log out of Second Shop?",
            style: GoogleFonts.lexend(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.lexend(color: Colors.grey),
              ),
            ),
            TextButton(
              child: Text(
                "Logout",
                style: GoogleFonts.lexend(
                  color: AuraTheme.primaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    // 1. CHECK IF USER IS NULL
    if (userProvider.user == null) {
      print("DEBUG: UserProvider.user is NULL. Stuck here.");
      return const Scaffold(
        body: Center(child: Text("User session not found. Please log in.")),
      );
    }

    final String userId = userProvider.user?['id'] ?? "";
    print("DEBUG: Attempting to fetch profile for UID: $userId");
    const Color primaryColor = Color(0xFF065F46);
    const Color backgroundColor = Color(0xFFF7FAF6);
    const Color surfaceContainer = Color(0xFFE1E9E2);

    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService.getUserProfile(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: primaryColor)),
          );
        }
        // DEBUG 3: Catch exact API errors
        if (snapshot.hasError) {
          print("DEBUG: API Error: ${snapshot.error}");
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text("Connection Error: ${snapshot.error}"),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text("No data returned from server")),
          );
        }

        // 2. SAFE DATA EXTRACTION
        final userData = snapshot.data!['user'] ?? {};
        final stats = snapshot.data!['statistics'] ?? {};
        final listings = (snapshot.data!['listings'] as List?) ?? [];

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            leading: const Icon(Icons.menu, color: primaryColor),
            title: Text(
              'Second Shop',
              style: GoogleFonts.lexend(
                color: primaryColor,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                onPressed: () => _showLogoutDialog(context),
              ),
              IconButton(
                icon: const Icon(Icons.search, color: primaryColor),
                onPressed: () {},
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(
                          'https://via.placeholder.com/150',
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData['name'] ?? "Guest User",
                              style: GoogleFonts.lexend(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  userData['location'] ?? "No Location",
                                  style: GoogleFonts.lexend(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone,
                                  size: 16,
                                  color: primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  userData['phone'] ?? "No Phone",
                                  style: GoogleFonts.lexend(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Reliability Score: ${stats['trustScore'] ?? '0'}",
                        style: GoogleFonts.lexend(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: (stats['trustScore'] != null)
                            ? (double.tryParse(
                                        stats['trustScore'].toString(),
                                      ) ??
                                      0.0) /
                                  100
                            : 0.0,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    _buildTab("Selling", isActive: true, primary: primaryColor),
                    const SizedBox(width: 24),
                    _buildTab("Sold", primary: primaryColor),
                    const SizedBox(width: 24),
                    _buildTab("Reviews", primary: primaryColor),
                  ],
                ),
                const SizedBox(height: 24),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(
                      listings[index],
                      primaryColor,
                      surfaceContainer,
                    );
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- Helper UI Widgets (Keep these outside the State class) ---

Widget _buildTab(
  String label, {
  required Color primary,
  bool isActive = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.lexend(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isActive ? primary : Colors.grey[400],
        ),
      ),
      if (isActive)
        Container(
          margin: const EdgeInsets.only(top: 4),
          height: 3,
          width: 20,
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
    ],
  );
}

Widget _buildProductCard(
  Map<String, dynamic> product,
  Color primary,
  Color surface,
) {
  final List images = product['images'] ?? [];
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(
                images.isNotEmpty
                    ? images[0]
                    : 'https://via.placeholder.com/150',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        product['name'] ?? "No Title",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
      ),
      Text(
        "${product['category'] ?? 'Item'} • \$${product['price'] ?? '0'}",
        style: GoogleFonts.lexend(color: Colors.grey, fontSize: 12),
      ),
    ],
  );
}
