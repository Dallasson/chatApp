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
                Image.asset('assets/images/error.png',height: 70,width: 70,color: Colors.black54,),
                SizedBox(height: 5,),
                Text('Something wrong...',style: TextStyle(color: Colors.black54),)
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
                    Material(
                      elevation: 12,
                      borderRadius: BorderRadius.circular(60),
                      child: Container(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.transparent,
                          backgroundImage: NetworkImage(imageUrl ?? 'assets/images/error.png'),
                        ),
                      ),
                    ),
                    SizedBox(height: 30,),
                    Padding(
                      padding: const EdgeInsets.only(left: 40,right: 40,top: 20),
                      child: TextFormField(
                        initialValue: email ,
                        style: TextStyle(fontFamily: 'sf',color: Colors.black38),

                      ),
                    ),
                    SizedBox(height: 30,),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40,left:40,right: 20),
                      child: TextFormField(
                        initialValue: userName,
                        style: TextStyle(fontFamily: 'source',color: Colors.black38),
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
                    Image.asset('assets/images/error.png',height: 70,width: 70,color: Colors.black54,),
                    SizedBox(height: 5,),
                    Text('Something wrong...',style: TextStyle(color: Colors.black54),)
                  ],
                ),
              );
            }
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/error.png',height: 70,width: 70,color: Colors.black54,),
              SizedBox(height: 5,),
              Text('Something wrong...',style: TextStyle(color: Colors.black54),)
            ],
          ),
        );
      },
    );
  }
}
