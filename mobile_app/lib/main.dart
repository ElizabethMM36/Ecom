import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:mobile_app/screens/auth/login.dart';
import 'package:mobile_app/screens/home/home_page.dart';
import 'package:mobile_app/screens/product_detail_screen.dart';
import 'core/theme/aura_theme.dart';
import 'features/listing/listing_screen.dart';
import 'screens/product_detail_screen.dart';

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
      title: 'Aura',
      debugShowCheckedModeBanner: false,
      theme: AuraTheme.light,
      home: ProductDetailScreen(product: demoProduct),
    );
  }
}
