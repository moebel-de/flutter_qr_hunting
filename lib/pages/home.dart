import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qrcode_scanner/controllers/login_register_controller.dart';

class Userprop {
  final String name;
  final int scannedDocuments;

  Userprop({required this.name, required this.scannedDocuments});
}

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final User? user = Auth().currentUser;

  Future<void> signout() async {
    await Auth().signout();
  }

  Stream<int> getUserScansCount(String userId) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    return firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.data()?['totalScans'] ?? 0);
  }

  _userId() {
    String userEmail = user?.email as String;
    List<String> parts = userEmail.split('.');
    if (parts.length >= 2) {
      String name = parts[0];
      String firstLetterAfterDot = parts[1].substring(0, 1).toUpperCase();
      return Text(
          'Moin ${name[0].toUpperCase()}${name.substring(1)}.$firstLetterAfterDot');
    } else {
      return const Text('Invalid email format');
    }
  }

  Widget _laederBoard() {
    final List<String> propUser = [
      'Test1',
      'Test2',
      'Test3',
      'Test4',
      'Test5',
      'Test6',
      'Test7'
    ];
    return SizedBox(
      width: 100,
      height: 200,
      child: Text(
        propUser.map((user) => '$user\n').join(),
      ),
    );
  }

  Widget _userCount() {
    return SizedBox(
      height: 100,
      width: 200,
      child: Card(
        color: Colors.deepOrange,
        child: Center(
          child: StreamBuilder(
            stream: getUserScansCount(user?.uid ?? ''),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              final scanCount = snapshot.data ?? 0;
              return Text(
                'Your Scans: $scanCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _goToQrCodeScanner(BuildContext context) {
    return ElevatedButton(
        child: const Text('Qr Scanner'),
        onPressed: () {
          Navigator.pushNamed(context, 'qrscanner');
        });
  }

  Widget _spacer() {
    return const SizedBox(
      height: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: _userId(),
          leading: const Icon(Icons.account_circle_rounded),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            signout();
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          },
          backgroundColor: Colors.deepOrange,
          child: const Icon(Icons.logout_rounded),
        ),
        body: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _laederBoard(),
              _userCount(),
              _spacer(),
              _goToQrCodeScanner(context),
            ],
          ),
        ));
  }
}
