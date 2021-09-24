import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:language/authentication/auth.dart';
import 'package:language/models/user.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:language/screens/status.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: MyApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool isVisible = true;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        isVisible = false;
      });
      Route route = MaterialPageRoute(builder: (context) => StatusPage());
      Navigator.pushReplacement(context, route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel?>.value(
        value: AuthService().onStatusChanged,
        initialData: null,
        catchError: (_, __) => null,
        child: SafeArea(
          child:  Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20,),
                Center(
                  child :  SvgPicture.asset("assets/svg/logo.svg")
                ),
                SizedBox(height: 30,),
                Text("Welcome To Chat",style: TextStyle(fontFamily: 'sf',color: Colors.black,fontWeight: FontWeight.bold,fontSize:25),),
                SizedBox(height: 10,),
                Text("Messaging Has Never Been Funnier",style: TextStyle(fontFamily: 'sf',color: Colors.black,fontSize:15),),
                SizedBox(height: 40,),
                SvgPicture.asset("assets/svg/spalshicon.svg"),
                SizedBox(height: 80,),
                Container(
                  width: 100,
                  child: Visibility(
                    visible: isVisible,
                    child: LinearProgressIndicator(),
                  ),
                )
              ],
            ),
          ),
        ),
    );
  }
}
