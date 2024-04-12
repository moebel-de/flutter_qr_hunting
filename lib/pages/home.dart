import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qrcode_scanner/controllers/login_register_controller.dart';

class HomePage extends StatelessWidget{
  HomePage({super.key});

  final User? user = Auth().currentUser;

  Future<void> signout() async{
    await Auth().signout();
  }

  Stream<int> getUserScansCount(String userId) {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  return firestore.collection('users').doc(userId)
    .snapshots()
    .map((snapshot) => snapshot.data()?['totalScans'] ?? 0);
}

  Widget _title(){
    return const Text('Moabel App');
  }

  Widget _userId() {
    return Text(user?.email ?? 'user Email');
  }

  Widget _laederBoard() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Test Name')
      ],
    );
  }

  Widget _userCount(){
    return StreamBuilder(stream: getUserScansCount(user?.uid ?? ''), 
    builder:(context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        final scanCount = snapshot.data ?? 0;
        return Text('Total Scans: $scanCount');
      },
    );
  }

  Widget _goToQrCodeScanner(BuildContext context){
    return 
    ElevatedButton(
      child: const Text('Qr Scanner'),
      onPressed: () {
        Navigator.pushNamed(context, 'qrscanner');
      } 
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: _title(),
        leading: const Icon(Icons.account_circle_rounded),
        
      ),
     floatingActionButton: FloatingActionButton(
        onPressed: () {
          signout();
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        },
        child: Icon(Icons.logout_rounded),
        backgroundColor: Colors.deepOrange,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //_laederBoard(),
            _userCount(),
            _userId(),
            _goToQrCodeScanner(context),
          ],
        ),
      )
    );
  }
}

