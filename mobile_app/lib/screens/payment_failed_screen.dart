import 'package:flutter/material.dart';
import '../core/theme/aura_theme.dart';

import 'checkout_screen.dart';

class PaymentFailedScreen extends StatelessWidget {
  const PaymentFailedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Status')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AuraTheme.errorContainer.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error, size: 40, color: AuraTheme.error),
            ),
            const SizedBox(height: 24),
            const Text(
              'Transaction Failed',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AuraTheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'We couldn\'t process your payment. Please check your card details or try a different method.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AuraTheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AuraTheme.errorContainer.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AuraTheme.error.withOpacity(0.1)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info, color: AuraTheme.error),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REASON FOR FAILURE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AuraTheme.error,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'The transaction was declined by your bank. This may be due to insufficient funds.',
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
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CheckoutScreen()),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: AuraTheme.satinGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Retry Payment',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
