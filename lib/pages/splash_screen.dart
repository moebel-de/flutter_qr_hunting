import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      body: Center(
        child: Image.asset('assets/images/moebel_de_logo_ci.png'),
      ),
    );
  }

  @override
  void dispose() {
    stream.cancel();
    super.dispose();
  }

  void _checkNextPage() {
    stream = Auth().authStateChanges.listen((event) {
      if (event != null) {
        _goToHomePage();
      } else {
        _goToLoginPage();
      }
    });
  }

  void _goToHomePage() async {
    if (await needMoreInfo()) {
      Navigator.pushNamedAndRemoveUntil(context, 'moreInfo', (route) => false);
    } else {
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
    }
  }

  Future<bool> needMoreInfo() async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().currentUser!.uid)
        .get()
        .then((value) {
      if (value.data() != null) {
        if (value['username'] != null) {
          return false;
        } else {
          return true;
        }
      } else {
        return true;
      }
    });
    return result;
  }

  void _goToLoginPage() async {
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
  }
}
