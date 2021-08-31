import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:language/authentication/auth.dart';
import 'package:language/chat/friends.dart';
import 'package:language/chat/profile.dart';
import 'package:language/chat/public.dart';
import 'package:language/models/user.dart';
import 'package:language/screens/auth/login.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  @override
  Widget build(BuildContext context) {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chat App'),
          actions: [
            IconButton(onPressed: (){
              AuthService().getUser(null);
              firebaseAuth.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
            }, icon: Icon(Icons.exit_to_app))
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Public',),
              Tab(text: 'History',),
              Tab(text: 'Profile',)
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PublicPage(),
            FriendsPage(),
            ProfilePage()
          ],
        ),
      ),
    );
  }
}
