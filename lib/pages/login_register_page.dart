import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import 'package:flutter_qrcode_scanner/controllers/login_register_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget{
  const LoginPage({super.key});

    @override
    State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text, 
        password: _controllerPassword.text,
      );
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final isFirstTime =  prefs.getBool('isFirstTime') ?? true;
        if(isFirstTime){
          await prefs.setBool('isFirstTime', false);
          Navigator.pushNamedAndRemoveUntil(context, 'intro', (route) => false);
        }else{
          // Just for testing and Designing the Intro Screen
          await prefs.setBool('isFirstTime', true);
          Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
        }
    }on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
      _showErrorSnackbar(errorMessage!);
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text, 
        password: _controllerPassword.text,
      );
       Navigator.pushNamedAndRemoveUntil(context, 'intro', (route) => false);
    }on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
      _showErrorSnackbar(errorMessage!);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.black),
          ),
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }

  Widget _title() {
    return const Text('Moebel App');
  }

  Widget _entryField(
    String title,
    TextEditingController controller,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
      validator: (value) {
        if (value == null || value.isEmpty){
          return 'Please enter a Email';
        }
        else if (value.isNotEmpty && !value.contains(RegExp('@'))){
          return 'Please enter a Valid Email';
        }
        else if (value.isNotEmpty && !value.contains(RegExp('moebel.de'))){
          return 'Please enter a Valid Moebel.de Email';
        }
        else {
          return null;
        }
      },
    );
  }

    Widget _entryFieldPw(
    String title,
    TextEditingController controller,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: title,
      ),
      validator: (value) {
        if (value == null || value.isEmpty){
          return 'Please enter a Password';
        }
        else if (value.isNotEmpty && !value.contains(RegExp(r'[A-Z]'))){
          return 'Please add a capital letter';
        }
        else if (value.isNotEmpty && value.length <= 8){
          return 'Password hast to be at least 8 characters';
        }
        else {
          return null;
        }
      },
    );
  }

 /*Widget _submitButtonTest(){
  return ElevatedButton(
    onPressed:
      isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
   child: Text(isLogin? 'login' : 'Register'),
   );
 }*/

  Widget _submitButton(){
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          if(isLogin){
            signInWithEmailAndPassword();
          }
          else {
            createUserWithEmailAndPassword();
          }
        }
      },
      child: Text(isLogin ? 'Login' : 'Register'), 
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
        });
      },
       child: Text(isLogin ? 'Register instead' : 'Login instead'),
      );
  }

@override
Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
          Navigator.pop(context);
            },
          ),
        title: _title(),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget> [
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Center(
                child: SizedBox(
                    width: 200,
                    height: 150,
                    child: Image.asset('assets/images/moebel_de_logo_ci.png')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: _entryField('Email', _controllerEmail)
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 0),
              child: _entryFieldPw('Password', _controllerPassword)
            ),
            _submitButton(),
            _loginOrRegisterButton()
          ],
          )
        ),
      ),
    );
  }
}

