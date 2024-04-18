import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qrcode_scanner/controllers/login_register_controller.dart';

class Leaderboard extends StatelessWidget {
  Leaderboard({super.key});

  final User? user = Auth().currentUser;

  Future<void> signout() async {
    await Auth().signout();
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

  Widget _leaderBoard() {
    return Column(
      children: [
        SizedBox(
          width: 300,
          height: 500,
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
                      child: Text('No one Started Yet'),
                    );
                  }

                  List<DocumentSnapshot> documents = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: documents.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = documents[index];
                      int scoreWithIndex = index + 1;
                      return Container(
                        decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: Colors.white30))
                                ),
                        child: ListTile(
                          title: Row(
                            children: [
                              _getUserIcon(document['userId']),
                              const SizedBox(width: 8),
                              Text(
                                '$scoreWithIndex. ${_getUserNames(document['email'].toString())} Points: ${document['score']}',
                                style: const TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
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
          title: const Text('Leaderboard'),
          leading: BackButton(
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
        ),
        body: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _leaderBoard(),
              _spacer(),
            ],
          ),
        ));
  }
}
