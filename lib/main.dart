import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qrcode_scanner/pages/home.dart';
import 'package:flutter_qrcode_scanner/pages/introscreen.dart';
import 'package:flutter_qrcode_scanner/pages/leaderboard.dart';
import 'package:flutter_qrcode_scanner/pages/login_register_page.dart';
import 'package:flutter_qrcode_scanner/pages/qr_scanner.dart';
import 'package:flutter_qrcode_scanner/pages/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp ({super.key});
  
  @override
  Widget build(BuildContext context){
    return  MaterialApp(
      initialRoute: '/',
      routes:{
        '/':(context) => const SplashScreen(),
        'home':(context) =>  HomePage(),
        'login':(context) => const LoginPage(),
        'intro':(context) => const IntroScreen(),
        'qrscanner':(context) => const QrScanner(),
        'leaderboard':(context) => Leaderboard(),
      } ,
    );
  }
}