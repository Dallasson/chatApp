import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:language/authentication/auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DataSnapshot?>(
      future: AuthService().getUserDetails(),
      builder: (context,data){
        if(data.hasError){
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/error.png',height: 70,width: 70,),
                SizedBox(height: 5,),
                Text('Nothing Found')
              ],
            ),
          );
        }
        if(data.connectionState == ConnectionState.done){
            if(data.data!.exists){
              var email = data.data!.value['email'];
              var userName = data.data!.value['userName'];
              var imageUrl = data.data!.value['userImage'];
              return Container(
                child: Column(
                  children: [
                    SizedBox(height: 40,),
                    Container(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.transparent,
                        backgroundImage: NetworkImage(imageUrl ?? ''),
                      ),
                    ),
                    SizedBox(height: 30,),
                    Padding(
                      padding: const EdgeInsets.only(left: 20,right: 20,top: 20),
                      child: TextFormField(
                        initialValue: email ,
                        style: TextStyle(fontFamily: 'source'),
                        enabled: false,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(height: 30,),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20,left: 20,right: 20),
                      child: TextFormField(
                        initialValue: userName,
                        enabled: false,
                        style: TextStyle(fontFamily: 'source'),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    )
                  ],
                ),
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/error.png',height: 70,width: 70,),
                    SizedBox(height: 5,),
                    Text('Nothing Found')
                  ],
                ),
              );
            }
        }
        return  Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/error.png',height: 70,width: 70,),
              SizedBox(height: 5,),
              Text('Nothing Found')
            ],
          ),
        );
      },
    );
  }
}
