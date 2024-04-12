import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_qrcode_scanner/controllers/login_register_controller.dart';

class QrScanner extends StatefulWidget{
  const QrScanner({super.key});

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner>{
  String _scanResult = '';
  final String _moebelPrefix = 'moebel-';

  final User? user = Auth().currentUser;
  
  @override
  void initState(){
    super.initState();
  }

  Future<void> scanCode() async {
    String barcodeScanRes;
    String checkedBarCode;
    try{
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666",
        "Cancel",
        true,
        ScanMode.QR);
        if(barcodeScanRes.startsWith(_moebelPrefix)){
          checkedBarCode = barcodeScanRes.substring(_moebelPrefix.length);
          sendQRCode(user?.uid ?? '', checkedBarCode);
        }
        else{
          checkedBarCode = "Dont Cheat thats a wrong barcode";
        }
    }on PlatformException {
      checkedBarCode = "Failed to scan the Bar Code, try again";
    }

    setState(() {
      _scanResult = checkedBarCode;
    });
  }

  Future<void> sendQRCode(String userId, String qrCodeContent) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference users = firestore.collection('users');
  
    DocumentReference userDoc = users.doc(userId);

    QuerySnapshot querySnapshot = await userDoc.collection('scans').where('code', isEqualTo: qrCodeContent).get();
    DocumentSnapshot documentSnapshot = await userDoc.get();

    if(!documentSnapshot.exists){
      await userDoc.set({
        'totalScans': 0,
        });
    }
  
    if (querySnapshot.docs.isNotEmpty) {
      return;
    }

  // Add the scan to the 'scans' subcollection
    await userDoc.collection('scans').add({
      'code': qrCodeContent,
      'scanDateTime': FieldValue.serverTimestamp(), // Use server timestamp
    });
  
    // Increment the total scans count
    await userDoc.update({
      'totalScans': FieldValue.increment(1),
    });
  }

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home:Scaffold(
        appBar: AppBar(
          leading: BackButton(
          onPressed: () {
          Navigator.pop(context);
            },
          ),
          title: const Text('QrScanner')),
        body: Builder(builder: (BuildContext context) {
          return Container(
            alignment: Alignment.center,
            child: Flex(
              direction: Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    scanCode();
                  }, 
                  child: const Text('Scan Qr Code')
                  ),
                 Text(_scanResult),
              ],
            ),
          );
        })
        )
    );
  }
}