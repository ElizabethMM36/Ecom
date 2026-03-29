import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Colors from your Tailwind Config
    const Color primaryColor = Color(0xFF476247);
    const Color onSurface = Color(0xFF1A2E24);
    const Color onSurfaceVariant = Color(0xFF5B7065);
    const Color backgroundColor = Color(0xFFFAFAF9);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // --- Background Decoration ---
          Positioned(
            top: -100,
            left: -100,
            child: _buildBlurCircle(
              const Color(0xFFD4F4D0).withOpacity(0.3),
              300,
            ),
          ),
          Positioned(
            bottom: -50,
            right: -100,
            child: _buildBlurCircle(
              const Color(0xFFF0FDF4).withOpacity(0.4),
              400,
            ),
          ),

          // --- Main Content ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Section
                  Column(
                    children: [
                      const SizedBox(height: 40),
                      _buildGlassIcon(primaryColor),
                      const SizedBox(height: 32),
                      Text(
                        'SecondShop',
                        style: GoogleFonts.lexend(
                          fontSize: 48,

                          color: onSurface,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PREMIER RESALE MARKETPLACE\nFOR CURATED TREASURES',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lexend(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: onSurfaceVariant,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),

                  // Middle Section (Large Storefront Icon)
                  _buildGlassPanel(
                    child: const Icon(
                      Icons.storefront_outlined,
                      size: 120,
                      color: primaryColor,
                    ),
                  ),

                  // Bottom Section (Actions)
                  Column(
                    children: [
                      _buildPrimaryButton(context, primaryColor),
                      const SizedBox(height: 16),
                      _buildSecondaryButton(context, onSurfaceVariant),
                      const SizedBox(height: 32),
                      _buildFooterMeta(onSurfaceVariant),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI Components ---

  Widget _buildBlurCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildGlassIcon(Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Icon(Icons.eco_outlined, color: color, size: 40),
        ),
      ),
    );
  }

  Widget _buildGlassPanel({required Widget child}) {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.white.withOpacity(0.4),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/register'),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          elevation: 10,
          shadowColor: color.withOpacity(0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Get Started',
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, Color textColor) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () =>
            Navigator.pushNamed(context, '/login'), // Navigate to login
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          side: BorderSide(color: textColor.withOpacity(0.3), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: Text(
          'Log In',
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildFooterMeta(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 30, height: 1, color: color.withOpacity(0.2)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'EST. 2024',
            style: GoogleFonts.lexend(
              fontSize: 10,
              letterSpacing: 2,
              color: color.withOpacity(0.6),
            ),
          ),
        ),
        Container(width: 30, height: 1, color: color.withOpacity(0.2)),
      ],
    );
  }
}
