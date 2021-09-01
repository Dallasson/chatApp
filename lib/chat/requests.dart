import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:language/authentication/auth.dart';
import 'package:language/models/request.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({Key? key}) : super(key: key);

  @override
  _RequestsPageState createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {

  List<RequestModel> list = [];

  String currentUserName = '';

  @override
  Widget build(BuildContext context) {
    list.clear();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1b1e44),
        title: Text('Requests'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(child: FutureBuilder<DataSnapshot>(
            future: AuthService().getFriendRequest(),
            builder: (context,data){
              if(data.hasError){
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/error.png',height: 70,width: 70,color: Colors.white,),
                      SizedBox(height: 5,),
                      Text('Nothing Found',style: TextStyle(color: Colors.white),)
                    ],
                  ),
                );
              }
              if(data.connectionState == ConnectionState.done){
                if(data.data!.exists){
                  Map<dynamic,dynamic> map = data.data!.value;
                  for(var child in map.values){
                    var userName = child['userName'];
                    var status = child['status'];
                    var senderId = child['senderId'];
                    var time = child['time'];

                    list.add(RequestModel(userName: userName, status: status, senderId: senderId, time: time));
                  }
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context,index){
                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          height: 110,
                          child: Card(
                            elevation: 10,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Text(list[index].userName,style: TextStyle(fontFamily: 'source',fontSize: 19),),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Text(list[index].status,style: TextStyle(fontFamily: 'source'),),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(child: Padding(
                                      padding: const EdgeInsets.only(left: 5,right: 5),
                                      child: ElevatedButton(onPressed: (){
                                        AuthService().updateFriendRequest('accepted',list[index].senderId,currentUserName);
                                        AuthService().updateCurrentUserFriends('accepted',FirebaseAuth.instance.currentUser!.uid,list[index].senderId,list[index].userName);
                                        AuthService().deleteUserFriendship(list[index].senderId);
                                        setState(() {
                                          list.removeAt(index);
                                        });

                                      }, child: Text('Accept')),
                                    )),
                                    Expanded(child: Padding(
                                      padding: const EdgeInsets.only(left: 5,right: 5),
                                      child: ElevatedButton(onPressed: (){
                                        AuthService().deleteUserFriendship(list[index].senderId);
                                        setState(() {
                                          list.removeAt(index);
                                        });
                                      }, child: Text('Reject')),
                                    ))
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/error.png',height: 70,width: 70,color: Colors.white,),
                    SizedBox(height: 5,),
                    Text('Nothing Found',style: TextStyle(color: Colors.white),)
                  ],
                ),
              );
            },
          )),
          Container(
            height: 60,
            child:  FutureBuilder<DataSnapshot>(
              future: AuthService().getUserDetails(),
              builder: (context,data){
                if(data.hasError){
                  return Center(
                    child: Text(''),
                  );
                }
                if(data.connectionState == ConnectionState.done){
                  currentUserName = data.data!.value['userName'];
                  var imageUrl = data.data!.value['userImage'];

                  return Text('');
                }
                return Text('');
              },
            ),
          ),
        ],
      ),
    );
  }
}
