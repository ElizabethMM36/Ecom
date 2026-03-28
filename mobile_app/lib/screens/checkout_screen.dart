import 'package:flutter/material.dart';
import '../core/theme/aura_theme.dart';
import 'payment_success_screen.dart';
import 'payment_failed_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedPaymentMethod = 1; // 1 = Stripe

  // Mocking the Stripe Payment Gateway Flow
  void _processStripePayment() async {
    // Show a loading indicator to simulate Stripe SDK initializing
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AuraTheme.primary),
      ),
    );

    // TODO: Replace with actual flutter_stripe initialization and confirmation
    // await Stripe.instance.initPaymentSheet(...);
    // await Stripe.instance.presentPaymentSheet();

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pop(context); // Remove loading dialog

    // Simulate success (You can change this boolean to test the failure screen)
    bool paymentSuccessful = true;

    if (paymentSuccessful) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PaymentSuccessScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PaymentFailedScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Review your order',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AuraTheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            _buildProductCard(),
            const SizedBox(height: 32),
            _buildDeliverySection(),
            const SizedBox(height: 32),
            _buildPaymentSummary(),
            const SizedBox(height: 24),
            _buildPaymentSelection(),
            const SizedBox(height: 32),
            _buildPayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AuraTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AuraTheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://via.placeholder.com/150',
                ), // Replace with actual asset
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Ethereal Bloom Concentré',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AuraTheme.primary,
                        ),
                      ),
                    ),
                    Text(
                      '\$124.00',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AuraTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Artisanally distilled forest flora, 50ml. Limited winter batch.',
                  style: TextStyle(
                    color: AuraTheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AuraTheme.primaryContainer.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 12,
                        color: AuraTheme.primaryContainer,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'IN STOCK',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AuraTheme.primaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliverySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.local_shipping_outlined, color: AuraTheme.primary),
                SizedBox(width: 8),
                Text(
                  'Delivery Destination',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AuraTheme.primary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'EDIT ADDRESS',
                style: TextStyle(
                  fontSize: 12,
                  color: AuraTheme.primaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AuraTheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SHIPPING ADDRESS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AuraTheme.secondary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '221B Botanical Avenue\nGarden District, Unit 402\nPortland, OR 97201\nUnited States',
                style: TextStyle(color: AuraTheme.onSurface, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AuraTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AuraTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Subtotal', '\$124.00'),
          const SizedBox(height: 8),
          _buildSummaryRow('Shipping', '\$12.00'),
          const SizedBox(height: 8),
          _buildSummaryRow('Tax (Botanical Excise)', '\$8.40'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.black12),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AuraTheme.primary,
                  fontSize: 16,
                ),
              ),
              Text(
                '\$144.40',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AuraTheme.primary,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AuraTheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AuraTheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SELECT PAYMENT METHOD',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AuraTheme.secondary,
          ),
        ),
        const SizedBox(height: 12),
        // Razorpay removed as requested, leaving only Stripe
        GestureDetector(
          onTap: () => setState(() => _selectedPaymentMethod = 1),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedPaymentMethod == 1
                    ? AuraTheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.credit_card, color: AuraTheme.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Stripe',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AuraTheme.primary,
                    ),
                  ),
                ),
                Radio(
                  value: 1,
                  groupValue: _selectedPaymentMethod,
                  onChanged: (val) =>
                      setState(() => _selectedPaymentMethod = val as int),
                  activeColor: AuraTheme.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPayButton() {
    return Column(
      children: [
        InkWell(
          onTap: _processStripePayment,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              gradient: AuraTheme.satinGradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AuraTheme.primaryContainer.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'PAY NOW',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'By clicking Pay Now, you agree to the Aura\nTerms of Service and Atelier Guidelines.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, color: AuraTheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
