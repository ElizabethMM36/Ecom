import 'package:flutter/material.dart';
import 'package:mobile_app/screens/auth/register.dart';
import 'package:mobile_app/screens/post_product/product_listing.dart';
import 'package:provider/provider.dart'; // 1. ADD THIS FOR MULTIPROVIDER
import 'package:mobile_app/providers/location_provider.dart'; // 2. ADD THIS FOR LOCATIONPROVIDER
import 'package:flutter/services.dart';
import 'package:mobile_app/screens/auth/login.dart';
import 'package:mobile_app/screens/home/home_page.dart';
import 'package:mobile_app/screens/orders/orders_page.dart';
import 'package:mobile_app/screens/product_detail_screen.dart';
import 'package:mobile_app/screens/profile/profile_page.dart';
import 'package:mobile_app/widgets/global_nav_bar.dart';
import 'core/theme/aura_theme.dart';
import 'features/listing/listing_screen.dart';
import '../../widgets/location_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Edge-to-edge UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SecondShop',
      debugShowCheckedModeBanner: false,
      theme: AuraTheme.light,
      routes: {
        '/': (context) => const MainWrapper(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});
  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const HomePage(),
    ProductListingPage(categoryTitle: 'electronics'),
    const ListingScreen(),
    const OrdersPage(),
    const ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // This is the "Edge-to-Edge" trick:
      // It ensures the body content doesn't get cut off by the navbar
      extendBody: true,
      body: _screens[_selectedIndex],
      bottomNavigationBar: AuraBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
