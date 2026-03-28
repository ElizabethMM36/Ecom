import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/theme/aura_theme.dart';
import 'package:mobile_app/screens/auth/login.dart';
import '../../widgets/global_nav_bar.dart';

class ProfilePage extends StatefulWidget {
  final int selectedIndex; // Changed from const to final field

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
    // Theme Colors based on your HTML setup
    const Color primaryColor = Color(0xFF065F46);
    const Color backgroundColor = Color(0xFFF7FAF6);
    const Color surfaceContainer = Color(0xFFE1E9E2);
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
          // LOGOUT BUTTON
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
                  CircleAvatar(
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
                          "Julianna Vance", // Dynamic
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
                            Text(
                              " Portland, OR",
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
                            Text(
                              " +91 9876564689",
                              style: GoogleFonts.lexend(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: [
                            "Tech Enthusiast",
                            "Eco-Conscious",
                          ].map((tag) => _buildTag(tag)).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // --- Reliability Card ---
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
                    "Reliability Score",
                    style: GoogleFonts.lexend(color: Colors.white70),
                  ),
                  Text(
                    "98/100",
                    style: GoogleFonts.lexend(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Top 1% of sellers this month.", // Dynamic
                    style: GoogleFonts.lexend(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: 0.98,
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

            // --- Tabs ---
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

            // --- Active Listings Grid ---
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return _buildProductCard(primaryColor, surfaceContainer);
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

Widget _buildTag(String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFEDF2ED),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: GoogleFonts.lexend(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
      ),
    ),
  );
}

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

Widget _buildProductCard(Color primary, Color surface) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            image: const DecorationImage(
              image: NetworkImage('https://via.placeholder.com/300'), // Dynamic
              fit: BoxFit.cover,
            ),
          ),
          alignment: Alignment.bottomRight,
          padding: const EdgeInsets.all(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "\$00.00",
              style: GoogleFonts.lexend(
                color: primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        "Product Title",
        style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
      ),
      Text(
        "Condition • Details",
        style: GoogleFonts.lexend(color: Colors.grey, fontSize: 12),
      ),
    ],
  );
}
