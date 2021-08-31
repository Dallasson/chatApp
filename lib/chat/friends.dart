import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:language/authentication/auth.dart';
import 'package:language/chat/private.dart';
import 'package:language/models/private.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {

  List<PrivateModel> list = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Event?>(
      stream: AuthService().getLastMessage(),
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
        if(data.connectionState == ConnectionState.active){
           if(data.data!.snapshot.exists){
             Map<dynamic,dynamic> map = data.data!.snapshot.value;
             for(var child in map.values){
               var name = child['userName'];
               var imageUrl = child['imageUrl'];
               var message = child['message'];
               var userId = child['userId'];

               list.add(PrivateModel(name: name, imageUrl: imageUrl, message: message,userId: userId));
             }
             return ListView.builder(
               itemCount: list.length,
               itemBuilder: (context,index){
                 return Padding(
                   padding: const EdgeInsets.all(10),
                   child: GestureDetector(
                     child: Container(
                       height: 60,
                       child: Row(
                         children: [
                           CircleAvatar(
                             radius: 30,
                             backgroundColor: Colors.transparent,
                             backgroundImage: NetworkImage(list[index].imageUrl),
                           ),
                           SizedBox(width: 10,),
                           Expanded(
                             child: Padding(
                               padding: const EdgeInsets.only(top: 10),
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Text(list[index].name),
                                   SizedBox(height: 3,),
                                   Container(
                                     color : Colors.black12,
                                     child : Text(list[index].message),
                                   )
                                 ],
                               ),
                             ),
                           ),
                         ],
                       ),
                     ),
                     onTap: (){
                       Navigator.push(context, MaterialPageRoute(builder: (context) => PrivateChatPage(
                           id : list[index].userId
                       )));
                     },
                   ),
                 );
               },
             );
           }
           else {
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
        return Text('');
      }
    );
  }
}
