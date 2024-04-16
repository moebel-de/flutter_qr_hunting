import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qrcode_scanner/controllers/login_register_controller.dart';

class MoreInfoPage extends StatefulWidget {
  const MoreInfoPage({super.key});

  @override
  State<MoreInfoPage> createState() => _MoreInfoPageState();
}

class _MoreInfoPageState extends State<MoreInfoPage> {
  int selectedAvatar = -1;
  final TextEditingController _controllerUsername = TextEditingController();

  final User? user = Auth().currentUser;
  @override
  void initState() {
    _controllerUsername.addListener(() {
      setState(() {});
    });
    _controllerUsername.text = _nameSuggestion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: active()
              ? () async {
                  await _saveItems();
                  _goToHome();
                }
              : null,
          child: const Text('Continue'),
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                  'Please Set a user name and select an avatar to continue'),
              TextField(
                controller: _controllerUsername,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter your username',
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAvatar = index;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: selectedAvatar == index
                              ? Border.all(
                                  color: Colors.green,
                                  width: 5,
                                ) // Green border when selected
                              : null,
                          borderRadius: BorderRadius.circular(1000),
                        ),
                        child: Image.asset(
                          'assets/avatars/avatar_$index.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                    );
                  },
                  itemCount: 25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _nameSuggestion() {
    String userEmail = user?.email as String;
    List<String> parts = userEmail.split('.');
    if (parts.length >= 2) {
      String name = parts[0];
      String firstLetterAfterDot = parts[1].substring(0, 1).toUpperCase();
      return 
          '${name[0].toUpperCase()}${name.substring(1)}.$firstLetterAfterDot';
    } else {
      return 'Invalid email format';
    }
  }

  bool active() {
    if (_controllerUsername.text.isNotEmpty && selectedAvatar != -1) {
      return true;
    }
    return false;
  }

  Future<void> _saveItems() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().currentUser!.uid)
        .set({
      'username': _controllerUsername.text,
      'avatar': selectedAvatar,
    });
  }

  void _goToHome() {
    Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
  }
}
