import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:language/authentication/auth.dart';
import 'package:language/screens/auth/login.dart';
import 'package:language/screens/home.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  bool isLoading = false;
  String imageDownloadUrl = '';

  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _userNameController = new TextEditingController();

  var emailKey = GlobalKey<FormState>();
  var passwordKey = GlobalKey<FormState>();
  var userNameKey = GlobalKey<FormState>();

  late ImagePicker imagePicker;
  File? file;

  @override
  void initState() {
    super.initState();
    imagePicker = new ImagePicker();
  }

  void pickImageFromGallery() async {
    var pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        file = File(pickedFile.path);
      } else {
        print('Picked Image is null');
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _userNameController.dispose();
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
            Text("Sign Up to chat",style: TextStyle(fontFamily: 'sf',color: Colors.black,fontWeight: FontWeight.bold,fontSize:25),),
            SizedBox(height: 10,),
            Text("New account to enjoy discussions",style: TextStyle(fontFamily: 'sf',color: Colors.black,fontSize:15),),
            SizedBox(height: 40,),
            Expanded(
              child: Container(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                shape: BoxShape.rectangle,
                                border:
                                Border.all(width: 1.0, color: Colors.indigo)),
                            child: GestureDetector(
                              onTap: () async {
                                pickImageFromGallery();
                              },
                              child: file != null ? Image.file(file!, fit: BoxFit.scaleDown,)
                                  : Icon(
                                Icons.person,
                                size: 80,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 30, left: 20, right: 20, bottom: 20),
                          child: Form(
                            key: emailKey,
                            child: TextFormField(
                              controller: _emailController,
                              style: TextStyle(color: Colors.white),
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
                                      fontFamily: 'source', color: Colors.black38,fontSize: 16)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
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
                                  return 'Password should have at least 6 characters';
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
                                      fontFamily: 'source', color: Colors.black38,fontSize: 16)),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                          const EdgeInsets.only(left: 20, right: 20, top: 20),
                          child: Form(
                            key: userNameKey,
                            child: TextFormField(
                              obscureText: true,
                              controller: _userNameController,
                              style: TextStyle(color: Colors.black38),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter your username';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Colors.black38,
                                  ),
                                  labelText: 'UserName',
                                  labelStyle: TextStyle(
                                      fontFamily: 'source', color: Colors.black38)),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: 100,
                          child:  Visibility(
                            visible: isLoading,
                            child: Center(
                              child: LinearProgressIndicator(),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 40, right: 40),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              color: Colors.indigo
                            ),
                            child: FlatButton(
                                onPressed: () async {
                                  if (emailKey.currentState!.validate() &&
                                      passwordKey.currentState!.validate() &&
                                      userNameKey.currentState!.validate()) {

                                    setState(() {
                                      isLoading = true;
                                    });

                                    String email = _emailController.text;
                                    String password = _passwordController.text;
                                    String userName = _userNameController.text;

                                    if (file != null) {
                                      await AuthService().uploadUserImage(file!, email, userName, context)
                                          .then((value){
                                        imageDownloadUrl = value;

                                        AuthService().registerUser(email, password).then((value) {
                                          AuthService().registerUserDetails(email, userName, imageDownloadUrl);
                                          setState(() {
                                            isLoading = false;
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        HomePage()));
                                          });
                                        });

                                      });
                                    } else {
                                      Fluttertoast.showToast(msg: 'Please upload an image');
                                      setState(() {
                                        isLoading = true;
                                      });
                                    }
                                  }
                                },
                                child: Text(
                                  'Register',
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
                                      builder: (context) => LoginScreen()));
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                'Have Account !',
                                style: TextStyle(
                                    fontFamily: 'sf', color: Colors.black38),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
