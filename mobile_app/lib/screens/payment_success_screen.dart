import 'package:flutter/material.dart';
import 'package:mobile_app/screens/home/home_page.dart';
import '../core/theme/aura_theme.dart';
import '../screens/orders/orders_page.dart';
import '../main.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFA6F2D1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AuraTheme.primary.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_circle,
                size: 40,
                color: Color(0xFF002116),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Payment Successful',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AuraTheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your high-fidelity acquisition is being secured in the botanical vault.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AuraTheme.onSurfaceVariant),
            ),
            const SizedBox(height: 40),
            _buildOrderDetails(),
            const SizedBox(height: 24),
            _buildEscrowBox(),
            const SizedBox(height: 32),
            InkWell(
              onTap: () {},
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: AuraTheme.satinGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Confirm Receipt',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                // Navigate to MainWrapper instead of HomePage
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainWrapper()),
                  (route) =>
                      false, // This clears the navigation stack so the user can't go "back" to the success screen
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: AuraTheme.surfaceContainerHigh,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Back to Home',
                style: TextStyle(
                  color: AuraTheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AuraTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TRANSACTION IDENTITY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AuraTheme.secondary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'ORD_123458829',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AuraTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AuraTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT STATE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AuraTheme.secondary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'STATUS_ESCROW',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AuraTheme.primaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEscrowBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFA6F2D1).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info, color: AuraTheme.primaryContainer),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Escrow Protection Active',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AuraTheme.primary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Funds are held in a secure vault until you verify the item\'s condition.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AuraTheme.onSurfaceVariant,
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
