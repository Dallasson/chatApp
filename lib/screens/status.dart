import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:language/models/user.dart';
import 'package:language/screens/home.dart';
import 'package:language/screens/auth/login.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    UserModel? userModel = Provider.of<UserModel?>(context);
    if(userModel != null){
       print("Home page called");
       return HomePage();
    }  else {
      print('Login Page Called');
      return LoginScreen();
    }
  }
}
