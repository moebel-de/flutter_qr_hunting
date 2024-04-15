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
                      return ListTile(
                        title: Text(document['score'].toString()),
                        subtitle: Text('Score: ${document['email']}'),
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
          title: const Text('Leaderboard'),
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
              _leaderBoard(),
              _spacer(),
            ],
          ),
        ));
  }
}
