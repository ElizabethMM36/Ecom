import 'package:flutter/material.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/input_field.dart';
import '../../widgets/gradient_button.dart';
import '../../config/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  void handleLogin() async {
    setState(() => isLoading = true);

    // TODO: Call AuthService.login(emailController.text, passwordController.text)
    // For now, we simulate a successful login and navigate to Home
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: GlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.developer_mode,
                    size: 60,
                    color: Color.fromARGB(207, 1, 126, 30),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "TechHub Login",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    "Sign in to discover tech nearby",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  InputField(
                    hint: "Email Address",
                    controller: emailController,
                  ),
                  InputField(
                    hint: "Password",
                    controller: passwordController,
                    isPassword: true,
                  ),

                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: AppColors.gradientStart),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  isLoading
                      ? const CircularProgressIndicator(
                          color: AppColors.gradientStart,
                        )
                      : GradientButton(text: "LOGIN", onTap: handleLogin),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("New here?"),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/register'),
                        child: const Text(
                          "Create Account",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
