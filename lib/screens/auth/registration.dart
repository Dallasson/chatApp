

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:language/authentication/auth.dart';
import 'package:language/screens/auth/login.dart';


class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {

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
      if(pickedFile != null){
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
      backgroundColor: Colors.blueGrey,
      body:  Column(
        children: [
          Container(
            height: 200,
            child: Center(
              child: Text('Chatty',style: TextStyle(fontSize: 38,fontWeight: FontWeight.bold,fontFamily: 'pacifico'),),
            ),
          ),
          Expanded(
            child : Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30))
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Center(
                          child: GestureDetector(
                              onTap: () async {
                                pickImageFromGallery();
                              },
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.transparent,
                                child: file != null ? Image.file(file!,height: 100,width: 100,) : Icon(Icons.person),
                              )
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20,left: 20,right: 20,bottom: 20),
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
                        padding: const EdgeInsets.only(left: 20,right: 20),
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
                      Padding(
                        padding: const EdgeInsets.only(left: 20,right: 20,top: 20),
                        child: Form(
                          key: userNameKey,
                          child: TextFormField(
                            controller: _userNameController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                                labelText: 'UserName',
                                labelStyle: TextStyle(fontFamily: 'source')
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 50,),
                      Padding(
                        padding: const EdgeInsets.only(left: 40,right: 40),
                        child: Container(
                          width: double.infinity,
                          child:  ElevatedButton(
                              onPressed: (){
                                if(emailKey.currentState!.validate() && passwordKey.currentState!.validate()
                                    && userNameKey.currentState!.validate()){
                                  String email = _emailController.text;
                                  String password = _passwordController.text;
                                  String userName = _userNameController.text;

                                  AuthService().registerUser(email, password,userName,file!,context);

                                  _emailController.text = '';
                                  _passwordController.text = '';
                                  _userNameController.text = '';
                                }
                              },
                              child: Text('Register',style: TextStyle(fontFamily: 'source'),)),
                        ),
                      ),
                      SizedBox(height: 30,),
                      Center(
                        child: GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) =>  LoginScreen()));
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text('Have Account !',style: TextStyle(fontFamily: 'source'),),
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
    );
  }
}
