import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Assuming these are your existing widget paths

import '../../core/theme/aura_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuraTheme.backgroundColor,
      body: Stack(
        children: [
          // Background Accents (Blur effects)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AuraTheme.primaryGreen.withOpacity(0.05),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 48),
                    _buildLoginForm(),
                    const SizedBox(height: 32),
                    _buildFooter(),
                    const SizedBox(height: 48),
                    _buildBottomGallery(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Transform.rotate(
          angle: 0.05, // 3 degrees approx
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AuraTheme.botanicalGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AuraTheme.primaryGreen.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "Welcome to Second Shop",
          style: GoogleFonts.lexend(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF004532),
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Curating the extraordinary for you.",
          style: GoogleFonts.lexend(
            color: AuraTheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: AuraTheme.primaryGreen.withOpacity(0.08),
            blurRadius: 64,
            offset: const Offset(0, 32),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputLabel("Email Address"),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _emailController,
            hint: "hello@aura.com",
            icon: Icons.alternate_email,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInputLabel("Password"),
              Text(
                "Forgot Password?",
                style: GoogleFonts.lexend(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AuraTheme.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _passwordController,
            hint: "••••••••",
            icon: Icons.lock_open_outlined,
            isPassword: true,
          ),
          const SizedBox(height: 32),
          _buildSignInButton(),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.lexend(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: AuraTheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: GoogleFonts.lexend(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AuraTheme.onSurfaceVariant.withOpacity(0.4),
        ),
        filled: true,
        fillColor: AuraTheme.backgroundColor,
        suffixIcon: Icon(
          icon,
          color: AuraTheme.onSurfaceVariant.withOpacity(0.6),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 18,
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: AuraTheme.botanicalGradient,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: AuraTheme.primaryGreen.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () {
            // Handle Sign In Logic
          },
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Sign In",
                  style: GoogleFonts.lexend(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "New to the gallery?",
          style: GoogleFonts.lexend(
            color: AuraTheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            "Create Account",
            style: GoogleFonts.lexend(
              color: AuraTheme.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomGallery() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildGalleryItem(-0.2, 'https://via.placeholder.com/100x150'),
        const SizedBox(width: 16),
        _buildGalleryItem(0.0, 'https://via.placeholder.com/100x150'),
        const SizedBox(width: 16),
        _buildGalleryItem(0.15, 'https://via.placeholder.com/100x150'),
      ],
    );
  }

  Widget _buildGalleryItem(double rotation, String url) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: 60,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
      ),
    );
  }
}
