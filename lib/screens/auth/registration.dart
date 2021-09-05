import 'dart:io';
import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: Color(0xFF1b1e44),
      body: Column(
        children: [
          Container(
            height: 200,
            child: Center(
              child: Text(
                'Chatty',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'pacifico'),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Color(0xff2a2b44),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              shape: BoxShape.rectangle,
                              border:
                                  Border.all(width: 1.0, color: Colors.white)),
                          child: GestureDetector(
                            onTap: () async {
                              pickImageFromGallery();
                            },
                            child: file != null
                                ? Image.file(
                                    file!,
                                    fit: BoxFit.scaleDown,
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 80,
                                    color: Colors.white,
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
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(20)),
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: Colors.white,
                                ),
                                labelText: 'Email',
                                labelStyle: TextStyle(
                                    fontFamily: 'source', color: Colors.white)),
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
                            style: TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your password';
                              } else if (value.length < 6) {
                                return 'Password should have at least 6 characters';
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
                                labelText: 'Password',
                                labelStyle: TextStyle(
                                    fontFamily: 'source', color: Colors.white)),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 20, right: 20, top: 20),
                        child: Form(
                          key: userNameKey,
                          child: TextFormField(
                            controller: _userNameController,
                            style: TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(20)),
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                                labelText: 'UserName',
                                labelStyle: TextStyle(
                                    fontFamily: 'source', color: Colors.white)),
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
                          child: ElevatedButton(
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
                                style: TextStyle(fontFamily: 'source'),
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
                                  fontFamily: 'source', color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Visibility(
                        visible: isLoading,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
