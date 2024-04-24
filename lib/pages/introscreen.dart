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
          title: 'Moin',
          bodyWidget: const Column(
            children: [
              Text(
                "Thanks for taking part in the game. First there will be a short introduction to how everything works.\n\n "
                "Have fun.",
                style: TextStyle(color: Colors.black),
                textAlign: TextAlign.center,
              )
            ],
          ),
          image: const Center(
            child: Icon(Icons.waving_hand, size: 50.0),
          )),
      PageViewModel(
          title: 'What?',
          bodyWidget: const Column(
            children: [
              Text(
                "Qr hunt is a game where you have to find Qr codes that we hide in the Office. You have to Scann them with the App to be able to gain Points and win some Prices",
                style: TextStyle(color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          image: const Center(
            child: Icon(Icons.qr_code, size: 100.0),
          )),
      PageViewModel(
          title: 'Where to Search?',
          bodyWidget: const Column(
            children: [
              Text(
                "They are hidden in different places throughout the office. But you don't have to open cupboards or break down doors.\n\n"
                "There will be Qr codes hidden from Tuesday to Thursday. On each day we will hide new Qr Codes and remove the old once",
                style: TextStyle(color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          image: const Center(
            child: Icon(Icons.hide_image, size: 100.0),
          )),
      PageViewModel(
          title: 'Why take part?',
          bodyWidget: const Column(
            children: [
              Text(
                  "Every one that takes part can win something\n\n"
                  "1. 25€ Amazone gift Card + Trophy\n"
                  "2. 15€ Amzonee gift Card\n"
                  "3. 10€ Amazone gift Card\n\n"
                  "The winners will be announced on Thursday\n",
                style: TextStyle(color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          image: const Center(
            child: Icon(Icons.party_mode, size: 100.0),
          )),
    ];
  }
}
