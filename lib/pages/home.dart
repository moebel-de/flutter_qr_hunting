import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qrcode_scanner/controllers/login_register_controller.dart';

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

  Widget _getUserIcon(uid) {
    return FutureBuilder(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, snap) {
          final int avatar = snap.data?['avatar'] ?? -1;
          return avatar == -1
              ? const Icon(Icons.account_circle)
              : Image.asset('assets/avatars/avatar_$avatar.png', width: 24, height: 24);
        });
  }

  _getUserNames(String email) {
    List<String> parts = email.split('.');
    if (parts.length >= 2) {
      String name = parts[0];
      String firstLetterAfterDot = parts[1].substring(0, 1).toUpperCase();
      return '${name[0].toUpperCase()}${name.substring(1)}.$firstLetterAfterDot';
    } else {
      return 'Invalid email format';
    }
  }

  Widget _leaderBoard(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 250,
          height: 200,
          child: Card(
            color: Colors.deepOrange,
            child: Center(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('scores')
                    .orderBy('score', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error fetching data'),
                    );
                  } else if (!snapshot.hasData ||
                      snapshot.data == null ||
                      snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No one Started Yet\n'
                          'Be The First one'),
                    );
                  }

                  List<DocumentSnapshot> documents = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: documents.length > 3 ? 3 : documents.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = documents[index];
                      int scoreWithIndex = index + 1;
                      return ListTile(
                        title: Row(
                          children: [
                            _getUserIcon(document['userId']),
                            const SizedBox(width: 8),
                            Text('$scoreWithIndex. ${_getUserNames(document['email'].toString())} Points: ${document['score']}',
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,),
                          ]
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
        ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(const Color(0xFF22CAFF)),
            ),
            onPressed: () {
              Navigator.pushNamed(context, 'leaderboard');
            },
            child: const Text(
              'See Full Leaderboard',
              style: TextStyle(color: Colors.white),
            ))
      ],
    );
  }

  Widget _userCount() {
    return SizedBox(
      height: 100,
      width: 250,
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
                'Your Points: $scanCount',
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
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(const Color(0xFF22CAFF)),
        ),
        child: const Text(
          'Qr Scanner',
          style: TextStyle(color: Colors.white),
        ),
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
          shape: const Border(
              bottom: BorderSide(color: Colors.deepOrange, width: 4)),
          title: FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(Auth().currentUser?.uid)
                  .get(),
              builder: (context, snap) {
                final userName = snap.data?['username'] ?? '';
                return userName.isEmpty ? _userId() : Text('Moin $userName!');
              }),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(Auth().currentUser!.uid)
                    .get(),
                builder: (context, snap) {
                  final int avatar = snap.data?['avatar'] ?? -1;
                  return avatar == -1
                      ? const Icon(Icons.account_circle)
                      : Image.asset('assets/avatars/avatar_$avatar.png');
                }),
          ),
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
              _leaderBoard(context),
              _spacer(),
              _userCount(),
              _spacer(),
              _goToQrCodeScanner(context),
              // Dont know how to do it the rigth way, want the app to start a bit more at the top
              _spacer(),
              _spacer(),
              _spacer(),
            ],
          ),
        ));
  }
}
