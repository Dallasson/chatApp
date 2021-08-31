import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:language/authentication/auth.dart';
import 'package:language/screens/auth/password_recovery.dart';
import 'package:language/screens/auth/registration.dart';




class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  var emailKey = GlobalKey<FormState>();
  var passwordKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Column(
        children: [
          Container(
            height: 200,
            child: Center(
              child: Text('Chatty',style: TextStyle(fontSize: 38,fontWeight: FontWeight.bold,fontFamily: 'pacifico'),),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30))
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 40,left: 40,right: 40,bottom: 20),
                      child: Form(
                        key: emailKey,
                        child: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email),
                              labelText: 'Email',
                              labelStyle: TextStyle(fontFamily: 'source')
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40,right: 40),
                      child: Form(
                        key: passwordKey,
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.password_outlined),
                              labelText: 'Password',
                              labelStyle: TextStyle(fontFamily: 'source')
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.only(left: 40),
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => PasswordRecoveryPage()));
                        },
                        child: Text('Forgot Password !',style: TextStyle(fontFamily: 'source'),),
                      ),
                    ),
                    SizedBox(height: 50,),
                    Padding(
                      padding: const EdgeInsets.only(left: 40,right: 40),
                      child: Container(
                        width: double.infinity,
                        child:  ElevatedButton(
                            onPressed: (){
                              if(emailKey.currentState!.validate() && passwordKey.currentState!.validate()){
                                String email = _emailController.text;
                                String password = _passwordController.text;

                                AuthService().loginUser(email, password,context);
                              }
                            },
                            child: Text('Login',style: TextStyle(fontFamily: 'source'),)),
                      ),
                    ),
                    SizedBox(height: 30,),
                    Center(
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationPage()));
                        },
                        child: Text('No Account!',style: TextStyle(fontFamily: 'source'),),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

