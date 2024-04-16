import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qrcode_scanner/controllers/login_register_controller.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final _introKey = GlobalKey<IntroductionScreenState>();

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      key: _introKey,
      pages: _pages(),
      showDoneButton: true,
      showNextButton: false,
      showSkipButton: true,
      skip: const Text("Skip"),
      done: const Text("Done"),
      onDone: () {
        _goToHome();
      },
      onSkip: () {
        _goToHome();
      },
      baseBtnStyle: TextButton.styleFrom(
        backgroundColor: Colors.grey.shade200,
      ),
    );
  }

  _goToHome() async {
    if (await needMoreInfo()) {
      Navigator.pushNamedAndRemoveUntil(context, 'moreInfo', (route) => false);
    } else {
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

  _pages() {
    return [
      PageViewModel(
          title: 'Page One',
          bodyWidget: const Column(
            children: [
              Text(
                  'Welcome to the app! This is a description of how it works.'),
            ],
          ),
          image: const Center(
            child: Icon(Icons.waving_hand, size: 50.0),
          )),
      PageViewModel(
          title: 'Page Two',
          bodyWidget: const Column(
            children: [
              Text(
                  'Welcome to the app! This is a description of how it works.'),
            ],
          ),
          image: const Center(
            child: Icon(Icons.qr_code_2, size: 100.0),
          )),
      PageViewModel(
          title: 'Page Three',
          bodyWidget: const Column(
            children: [
              Text(
                  'Welcome to the app! This is a description of how it works.'),
            ],
          ),
          image: const Center(
            child: Icon(Icons.article_outlined, size: 100.0),
          )),
    ];
  }
}
