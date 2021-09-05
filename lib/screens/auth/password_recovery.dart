import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PasswordRecoveryPage extends StatefulWidget {
  const PasswordRecoveryPage({Key? key}) : super(key: key);

  @override
  _PasswordRecoveryPageState createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends State<PasswordRecoveryPage> {
  bool isLoading = false;
  TextEditingController _emailController = new TextEditingController();
  var emailKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    return Scaffold(
      backgroundColor: Color(0xFF1b1e44),
      body: Container(
        child: Column(
          children: [
            Container(
              height: 200,
              child: Center(
                child: Text(
                  'Password Recovery',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'pacifico'),
                ),
              ),
            ),
            Expanded(
                child: Container(
              decoration: BoxDecoration(
                  color: Color(0xff2a2b44),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30))),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Form(
                      key: emailKey,
                      child: TextFormField(
                        controller: _emailController,
                        style: TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value!.isEmpty) {
                            setState(() {
                              isLoading = false;
                            });
                            return 'Please enter your email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(20)),
                            prefixIcon: Icon(
                              Icons.password_outlined,
                              color: Colors.white,
                            ),
                            labelText: 'Email Address',
                            labelStyle: TextStyle(
                                fontFamily: 'source', color: Colors.white)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 40),
                    child: Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            Future.delayed(Duration(seconds: 2), () {
                              if (emailKey.currentState!.validate()) {
                                firebaseAuth.sendPasswordResetEmail(
                                    email: _emailController.text);
                                Fluttertoast.showToast(
                                    msg:
                                        'A recovery email was sent , please check your inbox.');
                                _emailController.text = '';
                                setState(() {
                                  isLoading = false;
                                });
                              } else {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            });
                          });
                        },
                        child: Text('Recover Password'),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Visibility(
                      visible: isLoading,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ))
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
