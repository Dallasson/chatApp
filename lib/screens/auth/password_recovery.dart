import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class PasswordRecoveryPage extends StatefulWidget {
  const PasswordRecoveryPage({Key? key}) : super(key: key);

  @override
  _PasswordRecoveryPageState createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends State<PasswordRecoveryPage> {

  TextEditingController _emailController = new TextEditingController();
  var emailKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Container(
        child: Column(
          children: [
            Container(
              height: 200,
              child: Center(
                child: Text('Password Recovery',style: TextStyle(fontFamily: 'source'),),
              ),
            ),
            Expanded(child:  Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(30),topLeft: Radius.circular(30))
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Form(
                      key: emailKey,
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                            border : OutlineInputBorder(),
                            prefixIcon: Icon(Icons.password_outlined),
                            labelText : 'Password',
                            labelStyle: TextStyle(fontFamily: 'source')
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20,right: 20),
                    child: Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (){
                          if(emailKey.currentState!.validate()){
                            firebaseAuth.sendPasswordResetEmail(email: _emailController.text);
                            Fluttertoast.showToast(msg: 'A recovery email was sent.');
                          }
                        },
                        child: Text('Recover Password'),
                      ),
                    ),
                  )
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
