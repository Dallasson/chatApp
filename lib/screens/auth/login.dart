import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:language/authentication/auth.dart';
import 'package:language/screens/auth/password_recovery.dart';
import 'package:language/screens/auth/registration.dart';
import 'package:language/screens/home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;

  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  var emailKey = GlobalKey<FormState>();
  var passwordKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20,),
            Center(
                child :  SvgPicture.asset("assets/svg/logo.svg")
            ),
            SizedBox(height: 30,),
            Text("Sign in to chat",style: TextStyle(fontFamily: 'sf',color: Colors.black,fontWeight: FontWeight.bold,fontSize:25),),
            SizedBox(height: 10,),
            Text("Get up And Chat with friends",style: TextStyle(fontFamily: 'sf',color: Colors.black,fontSize:15),),
            SizedBox(height: 40,),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 40, left: 40, right: 40, bottom: 20),
                      child: Form(
                        key: emailKey,
                        child: TextFormField(
                          controller: _emailController,
                          style: TextStyle(color: Colors.black38),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.email,
                                color: Colors.black38,
                              ),
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                  fontFamily: 'sf', color: Colors.black38,fontSize: 16)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      child: Form(
                        key: passwordKey,
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: TextStyle(color: Colors.black38),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your password';
                            } else if (value.length < 6) {
                              return 'Password is too short';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.password_outlined,
                                color: Colors.black38,
                              ),
                              suffixIcon: Icon(
                                Icons.visibility,
                                color: Colors.black38,
                              ),
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                  fontFamily: 'sf', color: Colors.black38,fontSize: 16)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Center(
                      child:  GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => PasswordRecoveryPage()));
                        },
                        child: Text(
                          'Forgot Password !',
                          style: TextStyle(
                              fontFamily: 'sf', color: Colors.black38,fontSize: 13,fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            color: Colors.indigo
                        ),
                        child: FlatButton(
                            onPressed: () {
                              if (emailKey.currentState!.validate() &&
                                  passwordKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                });
                                String email = _emailController.text;
                                String password = _passwordController.text;

                                AuthService().loginUser(email, password, context)
                                    .then((value){
                                  setState(() {
                                    isLoading = true;
                                    _emailController.text = '';
                                    _passwordController.text = '';
                                  });
                                  Navigator.pushReplacement(
                                      context, MaterialPageRoute(builder: (context) => HomePage()));
                                });
                              }
                            },
                            child: Text(
                              'Login',
                              style: TextStyle(fontFamily: 'sf',color: Colors.white),
                            )),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegistrationPage()));
                        },
                        child: Text(
                          'No Account!',
                          style: TextStyle(
                              fontFamily: 'source', color: Colors.black38,fontSize: 14),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                      width: 100,
                      child: Visibility(
                        visible: isLoading,
                        child: LinearProgressIndicator(),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
