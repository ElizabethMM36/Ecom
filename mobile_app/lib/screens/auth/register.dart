import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/services/api_service.dart';
import '../../core/theme/aura_theme.dart'; // Adjust path as needed

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _agreeToTerms = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  bool _isLoading = false;
  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the Terms & Conditions')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        age: _ageController.hashCode,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Account created')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The Mesh Gradient Background
      body: Stack(
        children: [
          const Positioned.fill(child: _MeshBackground()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildRegistrationCard(),
                  const SizedBox(height: 40),
                  _buildFooter(),
                  const SizedBox(height: 80), // Space for bottom nav
                ],
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
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF065F46), // Primary
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF065F46).withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 24),
        Text(
          'SecondShop',
          style: GoogleFonts.lexend(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.5,
            color: const Color(0xFF002117), // on-surface
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Create your botanical account',
          style: GoogleFonts.lexend(
            fontSize: 16,
            color: const Color(0xFF545F73), // on-surface-variant
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFBEC9C2).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF065F46).withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField(
              label: 'Full Name',
              hint: 'Alex Rivera',
              icon: Icons.person,
              controller: _nameController,
              validator: (v) => v!.isEmpty ? 'Enter your name' : null,
            ),
            const SizedBox(height: 24),
            _buildInputField(
              label: 'Email Address',
              hint: 'alex@aura.shop',
              icon: Icons.mail,
              controller: _emailController,
              validator: (v) =>
                  !v!.contains('@') ? 'Enter a valid email' : null,
            ),
            const SizedBox(height: 24),
            _buildInputField(
              label: 'Phone Number',
              hint: '+1 (555) 000-0000',
              icon: Icons.call,
              controller: _phoneController,
              validator: (v) => v!.isEmpty ? 'Enter your phone number' : null,
            ),
            const SizedBox(height: 24),
            _buildInputField(
              label: 'Password',
              hint: '••••••••••••',
              icon: Icons.lock,
              isPassword: true,
              controller: _passwordController,
              validator: (v) => v!.isEmpty ? 'Enter your password' : null,
            ),
            const SizedBox(height: 24),
            _buildInputField(
              label: 'age',
              hint: 'Above 18',
              icon: Icons.person,

              controller: _ageController,
              validator: (v) => v!.isEmpty ? 'Enter your age' : null,
            ),
            const SizedBox(height: 20),
            _buildTermsCheckbox(),
            const SizedBox(height: 32),
            _buildSignUpButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller, // Integrated
    bool isPassword = false,
    String? Function(String?)? validator, // Integrated
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Changed from 'child' to 'children'
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: const Color(0xFF545F73),
            ),
          ),
        ),
        TextFormField(
          controller: controller, // Added
          validator: validator, // Added
          obscureText: isPassword,
          style: GoogleFonts.lexend(color: const Color(0xFF002117)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.lexend(
              color: const Color(0xFF707973).withOpacity(0.6),
            ),
            filled: true,
            fillColor: const Color(0xFFF7FAF6),
            suffixIcon: Icon(
              icon,
              color: const Color(0xFF065F46).withOpacity(0.4),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBEC9C2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBEC9C2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF065F46),
                width: 1.5,
              ),
            ),
            // Added error styling so the validator messages look good
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _agreeToTerms,
          activeColor: const Color(0xFF065F46),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (val) => setState(() => _agreeToTerms = val!),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.lexend(
                color: const Color(0xFF545F73),
                fontSize: 13,
              ),
              children: const [
                TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms & Conditions',
                  style: TextStyle(
                    color: Color(0xFF065F46),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: ' and Privacy Policy.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF065F46),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 10,
          shadowColor: const Color(0xFF065F46).withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sign Up',
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account? ',
              style: GoogleFonts.lexend(color: const Color(0xFF545F73)),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Sign In',
                style: GoogleFonts.lexend(
                  color: const Color(0xFF065F46),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          height: 1,
          color: const Color(0xFFBEC9C2).withOpacity(0.3),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialButton('assets/google.png'), // Add your assets
            const SizedBox(width: 16),
            _socialButton('assets/apple.png'),
          ],
        ),
      ],
    );
  }

  Widget _socialButton(String asset) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFEDF2ED),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.ads_click, size: 20),
      ), // Placeholder
    );
  }
}

// Custom Painter to replicate the tailwind radial-gradient-mesh
class _MeshBackground extends StatelessWidget {
  const _MeshBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7FAF6),
      child: CustomPaint(painter: _MeshPainter()),
    );
  }
}

class _MeshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFF065F46).withOpacity(0.05),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: const Offset(0, 0),
              radius: size.width * 0.8,
            ),
          );

    final paint2 = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFF95D5B2).withOpacity(0.08),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width, size.height),
              radius: size.width * 0.8,
            ),
          );

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint1);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
