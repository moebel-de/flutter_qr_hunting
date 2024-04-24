import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_qrcode_scanner/controllers/login_register_controller.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  String _scanResult = '';
  final String _moebelPrefix = 'moebel-';

  final User? user = Auth().currentUser;

  @override
  void initState() {
    super.initState();
  }

  Future<void> scanCode() async {
    String barcodeScanRes;
    String checkedBarCode;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.QR);
      if (barcodeScanRes.startsWith(_moebelPrefix)) {
        checkedBarCode = barcodeScanRes.substring(_moebelPrefix.length);
        sendQRCode(user?.uid ?? '', checkedBarCode);
        checkedBarCode = "Your Scann Worked, Keep on Scanning";
        Navigator.pushNamed(context, 'home');
      } else {
        checkedBarCode = "Dont try to Cheat.\n"
            "Only our Qr Codes Work 😁";
      }
    } on PlatformException {
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

    QuerySnapshot querySnapshot = await userDoc
        .collection('scans')
        .where('code', isEqualTo: qrCodeContent)
        .get();
    DocumentSnapshot documentSnapshot = await userDoc.get();

    if (!documentSnapshot.exists) {
      await userDoc.set({
        'totalScans': 0,
      });
    }

    if (querySnapshot.docs.isNotEmpty) {
      return;
    }

    await userDoc.collection('scans').add({
      'code': qrCodeContent,
      'scanDateTime': FieldValue.serverTimestamp(),
    });

    await userDoc.update({
      'totalScans': FieldValue.increment(1),
    });

    int totalScans = 1;
    try {
      totalScans = documentSnapshot.get('totalScans');
    } catch (e) {
      print(e);
    }

    final playerSnapshotQuery =
        firestore.collection("scores").where("userId", isEqualTo: userId);

    final PlayerSnapShot = await playerSnapshotQuery.get();

    if (PlayerSnapShot.docs.isEmpty) {
      final user = Auth().currentUser;
      await firestore.collection("scores").doc().set(
          {"userId": userId, "score": totalScans + 1, "email": user?.email});
    } else {
      final docId = PlayerSnapShot.docs[0].id;
      await firestore
          .collection("scores")
          .doc(docId)
          .update({"userId": userId, "score": totalScans + 1});
    }
  }

  Widget _spacer() {
    return const SizedBox(
      height: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              shape: const Border(
                  bottom: BorderSide(color: Colors.deepOrange, width: 4)),
              leading: BackButton(
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: const Text('QrScanner'),
              centerTitle: true,
            ),
            body: Builder(builder: (BuildContext context) {
              return Container(
                alignment: Alignment.center,
                child: Flex(
                  direction: Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color.fromRGBO(255, 255, 255, 1)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: const BorderSide(color: Color(0xFF22CAFF)),
                            ),
                          ),
                        ),
                        onPressed: () {
                          scanCode();
                        },
                        child: const Wrap(
                          children: [
                            Icon(
                              Icons.qr_code,
                              color: Colors.black,
                              size: 24.0,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text('Open Qr Scanner',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20))
                          ],
                        )),
                    _spacer(),
                    SizedBox(
                      height: 100,
                      width: 200,
                      child: Card(
                        color: Colors.white,
                        child: Center(
                            child: Text(
                          _scanResult.isEmpty
                              ? 'You have to Scann a Qr Code'
                              : _scanResult,
                          style: const TextStyle(color: Colors.black),
                          textAlign: TextAlign.center,
                        )),
                      ),
                    ),
                  ],
                ),
              );
            })));
  }
}
