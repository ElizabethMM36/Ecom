import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app/core/providers/user_provider.dart';
import 'package:mobile_app/core/providers/location_provider.dart';
import 'package:mobile_app/core/services/api_service.dart';
import 'package:mobile_app/screens/auth/login.dart';
import 'package:mobile_app/screens/auth/register.dart';
import 'package:mobile_app/screens/auth/welcome_page.dart';
import 'package:mobile_app/screens/home/home_page.dart';
import 'package:mobile_app/screens/profile/profile_page.dart';
import 'package:mobile_app/screens/orders/orders_page.dart';
import 'package:mobile_app/screens/post_product/product_listing.dart';
import 'package:mobile_app/features/listing/listing_screen.dart';
import 'package:mobile_app/widgets/global_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SecondShop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: FutureBuilder<String?>(
        future: ApiService.getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF476247)),
              ),
            );
          }

          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.isNotEmpty) {
            // We use addPostFrameCallback to update Provider safely
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final userProvider = Provider.of<UserProvider>(
                context,
                listen: false,
              );
              if (userProvider.user == null) {
                userProvider.initializeFromToken(snapshot.data!);
              }
            });
            return const MainWrapper();
          }

          return const WelcomePage();
        },
      ),
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/home': (context) => const MainWrapper(),
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
