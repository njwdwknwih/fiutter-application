import 'package:babyshophub/controller/address_controller.dart';
import 'package:babyshophub/controller/auth_controller.dart';
import 'package:babyshophub/controller/cart_controller.dart';
import 'package:babyshophub/controller/navigation_controller.dart';
import 'package:babyshophub/controller/order_controller.dart';
import 'package:babyshophub/controller/product_controller.dart';
import 'package:babyshophub/controller/theme_controller.dart';
import 'package:babyshophub/controller/wishlist_controller.dart';
import 'package:babyshophub/utils/app_theme.dart';
import 'package:babyshophub/view/onboard/Splash.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: "https://sawzupjjmaijkgbyuexe.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNhd3p1cGpqbWFpamtnYnl1ZXhlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEyODEwNjAsImV4cCI6MjA2Njg1NzA2MH0._P3gquKDLI5wykosoaocQwlctu_oKFF0j5MOpw2Zpws",
    
  );
  // WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();

  Get.put(ThemeController());
  Get.put(CartController()); 
  Get.put(AddressController());
  Get.put(AuthController());
  Get.put(ProductController());
  Get.put(NavigationController());
  Get.put(WishlistController());
  Get.put(OrderController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() => GetMaterialApp(
          navigatorKey: Get.key,
          title: "Babies Shop",
          debugShowCheckedModeBanner: false,
          defaultTransition: Transition.fade,
          theme: AppThemes.light,
          darkTheme: AppThemes.dark,
          themeMode: themeController.themeMode,
          home: SplashScreen(),
        ));
  }
}
