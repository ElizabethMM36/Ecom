// --- MOCK DATA MODELS ---
// In a real app, these would live in lib/models/
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/global_nav_bar.dart';
import '../../core/theme/aura_theme.dart';

class Order {
  final String id;
  final String title;
  final String date;
  final double price;
  final String status; // 'Escrow Hold', 'Shipped', 'Delivered'
  final String imageUrl;
  final String? expectedDelivery;

  Order({
    required this.id,
    required this.title,
    required this.date,
    required this.price,
    required this.status,
    required this.imageUrl,
    this.expectedDelivery,
  });
}

class Transaction {
  final String title;
  final String subtitle;
  final double amount;
  final String date;
  final String type; // 'release', 'purchase', 'withdrawal'

  Transaction({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.type,
  });
}

// --- MAIN WIDGET ---
class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int _selectedTabIndex = 0;
  int _currentBottomNavIndex = 3;
  // Dynamic Lists replacing HTML hardcoded values
  final List<Order> activeOrders = [
    Order(
      id: 'ORD_123458829',
      title: 'Ethereal Bloom Concentré',
      date: 'Oct 24, 2023',
      price: 124.00,
      status: 'Escrow Hold',
      imageUrl:
          'https://images.unsplash.com/photo-1594035910387-fea47794261f?w=400',
    ),
    Order(
      id: 'ORD_123458712',
      title: 'Midnight Moss Candle',
      date: 'Oct 21, 2023',
      price: 48.00,
      status: 'Shipped',
      expectedDelivery: 'Oct 28, 2023',
      imageUrl:
          'https://images.unsplash.com/photo-1603006905003-be475563bc59?w=400',
    ),
  ];
  final List<Order> pastOrders = [
    Order(
      id: 'ORD_123456001',
      title: 'Fern Study Art Print',
      date: 'Oct 15, 2023',
      price: 85.00,
      status: 'Delivered',
      imageUrl:
          'https://images.unsplash.com/photo-1544274946-814d33a681cc?w=400',
    ),
  ];

  final List<Transaction> recentTransactions = [
    Transaction(
      title: 'Fund Release',
      subtitle: 'Sale: Velvet Terrarium',
      amount: 340.00,
      date: 'Oct 25, 2023',
      type: 'release',
    ),
    Transaction(
      title: 'Purchase Payment',
      subtitle: 'Ethereal Bloom Conc.',
      amount: -124.00,
      date: 'Oct 24, 2023',
      type: 'purchase',
    ),
    Transaction(
      title: 'Fund Release',
      subtitle: 'Sale: Silk Fern Tie',
      amount: 115.00,
      date: 'Oct 20, 2023',
      type: 'release',
    ),
  ];

  // Helper for click actions
  void _handleAction(String actionName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$actionName initiated.', style: GoogleFonts.lexend()),
        backgroundColor: const Color(0xFF004532),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF004532)),
          onPressed: () => _handleAction("Menu"),
        ),
        title: Text(
          'Aura',
          style: GoogleFonts.lexend(
            color: const Color(0xFF004532),
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Orders',
              style: GoogleFonts.lexend(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF004532),
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your acquisitions and  sales.',
              style: GoogleFonts.lexend(
                fontSize: 16,
                color: const Color(0xFF3F4944), // on-surface-variant
              ),
            ),
            const SizedBox(height: 32),
            _buildTabs(),
            const SizedBox(height: 32),
            // Based on tab index, you can swap views. Here we build the Buying view.
            _buildActiveShipments(),
            const SizedBox(height: 40),

            _buildRecentlyDelivered(),
            const SizedBox(height: 40),

            _buildTransactionHistory(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = ['Buying', 'Selling', 'Wallet'];
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x26BEC9C2))),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isActive = _selectedTabIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = index),
            child: Container(
              padding: const EdgeInsets.only(bottom: 12, right: 32),
              decoration: BoxDecoration(
                border: isActive
                    ? const Border(
                        bottom: BorderSide(color: Color(0xFF004532), width: 2),
                      )
                    : null,
              ),
              child: Text(
                tabs[index],
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive
                      ? const Color(0xFF004532)
                      : const Color(0xFF545F73),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActiveShipments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ACTIVE SHIPMENTS',
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF545F73),
                letterSpacing: 1.2,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFA6F2D1), // primary-fixed
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${activeOrders.length} IN TRANSIT',
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002116),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Map dynamic active orders to OrderCard
        ...activeOrders.map((order) => _buildOrderCard(order)),
      ],
    );
  }

  Widget _buildOrderCard(Order order) {
    bool isEscrow = order.status == 'Escrow Hold';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F0), // surface-container-low
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x26BEC9C2)), // ghost border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  order.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            order.title,
                            style: GoogleFonts.lexend(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF004532),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '\$${order.price.toStringAsFixed(2)}',
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF004532),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.id} • Purchased ${order.date}',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        color: const Color(0xFF545F73),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Status Badge
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isEscrow
                                ? Colors.amber[500]
                                : AuraTheme.accentGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          order.status,
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF3F4944),
                          ),
                        ),
                      ],
                    ),
                    if (order.expectedDelivery != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Expected delivery: ${order.expectedDelivery}',
                        style: GoogleFonts.lexend(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF545F73),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Actions
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (isEscrow)
                ElevatedButton(
                  onPressed: () =>
                      _handleAction("Confirm Receipt for ${order.id}"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF065F46,
                    ), // primary-container
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Confirm Receipt',
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              if (isEscrow)
                ElevatedButton(
                  onPressed: () => _handleAction("Track ${order.id}"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFFE6E9E5,
                    ), // surface-container-high
                    foregroundColor: const Color(0xFF181C1A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Track Order',
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              OutlinedButton(
                onPressed: () => _handleAction("Dispute filed for ${order.id}"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF545F73),
                  side: const BorderSide(color: Color(0xFF6F7973)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'Dispute',
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyDelivered() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECENTLY DELIVERED',
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF545F73),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x26BEC9C2)),
          ),
          child: Column(
            children: pastOrders.map((order) {
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    order.imageUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  order.title,
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  order.id,
                  style: GoogleFonts.lexend(
                    fontSize: 11,
                    color: const Color(0xFF545F73),
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${order.price.toStringAsFixed(2)}',
                      style: GoogleFonts.lexend(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD5E0F8).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        order.status,
                        style: GoogleFonts.lexend(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF586377),
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () => _handleAction("View details for ${order.title}"),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECENT TRANSACTIONS',
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF545F73),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        ...recentTransactions.map((tx) {
          // Dynamic Icons based on requested mapping
          IconData txIcon;
          Color iconBg;
          Color iconColor;
          Color amountColor;
          String amountPrefix = '';

          if (tx.type == 'release') {
            txIcon = Icons.call_received; // Fund release icon
            iconBg = const Color(0xFFC3ECD7);
            iconColor = const Color(0xFF002115);
            amountColor = AuraTheme.primary;
            amountPrefix = '+';
          } else {
            // purchase
            txIcon = Icons.shopping_cart_outlined; // Purchase payment icon
            iconBg = const Color(0xFFE0E3DF);
            iconColor = const Color(0xFF3F4944);
            amountColor = const Color(0xFF181C1A);
          }

          return InkWell(
            onTap: () => _handleAction("View transaction: ${tx.title}"),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(txIcon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.title,
                          style: GoogleFonts.lexend(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF004532),
                          ),
                        ),
                        Text(
                          tx.subtitle,
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            color: const Color(0xFF545F73),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$amountPrefix\$${tx.amount.abs().toStringAsFixed(2)}',
                        style: GoogleFonts.lexend(
                          fontWeight: FontWeight.bold,
                          color: amountColor,
                        ),
                      ),
                      Text(
                        tx.date,
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          color: const Color(0xFF545F73),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () => _handleAction("Load full statement"),
            child: Text(
              'View Statement History',
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF545F73),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
