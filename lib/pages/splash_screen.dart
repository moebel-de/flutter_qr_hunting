import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qrcode_scanner/controllers/login_register_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late StreamSubscription<User?> stream;

  @override
  void initState() {
    _checkNextPage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Image.asset('assets/images/moebel_de_logo_ci.png'),),
    );
  }

  @override
  void dispose() {
    stream.cancel();
    super.dispose();
  }

  void _checkNextPage() {
   stream = Auth().authStateChanges.listen((event) { 
        if(event!= null){
          _goToHomePage();
        }else{
          _goToLoginPage();
        }
    });
  }
  
  void _goToHomePage() async{
   await Future.delayed(const Duration(seconds: 1));
    Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
  }
  
  void _goToLoginPage() async{
  await  Future.delayed(const Duration(seconds: 1));
      Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);

  }
}