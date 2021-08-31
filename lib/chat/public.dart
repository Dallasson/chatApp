import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:language/authentication/auth.dart';
import 'package:language/chat/private.dart';
import 'package:language/models/message.dart';
import 'package:provider/provider.dart';

class PublicPage extends StatefulWidget {
  const PublicPage({Key? key}) : super(key: key);

  @override
  _PublicPageState createState() => _PublicPageState();
}

class _PublicPageState extends State<PublicPage> {

  TextEditingController textEditingController = new TextEditingController();

   List<MessageModel> list = [];

   String name ='';
   String message = '';
   String imageUrl = '';
   String userId = '';
   late MessageModel messageModel;
  @override
  Widget build(BuildContext context) {
    Provider.of<Event?>(context);
    list.clear();
    return Column(
      children: [
        Expanded(child: Container(
            child: StreamBuilder<Event?>(
              initialData: null,
            stream: AuthService().getMessages(),
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
                  Map<dynamic,dynamic> values = data.data!.snapshot.value;
                  for(var child in values.values){
                    name = child['userName'];
                    message = child['message'];
                    imageUrl = child['imageUrl'];
                    userId = child['userId'];
                    messageModel = MessageModel(name: name, imageUrl: imageUrl, message: message,userId: userId);
                    list.add(messageModel);
                  }

                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context,index){
                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: GestureDetector(
                          onTap: (){
                             if(list[index].userId != FirebaseAuth.instance.currentUser!.uid){
                               Navigator.push(context, MaterialPageRoute(builder: (context) => PrivateChatPage(
                                   id : list[index].userId
                               )));
                             }
                          },
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
                                IconButton(onPressed: (){
                                  PopupMenuButton(
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          child: Text("Send Message"),
                                          value: 1,
                                        ),
                                      ]
                                  );
                                }, icon: Icon(Icons.airplanemode_on))
                              ],
                            ),
                          ),
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
            },
          ),
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
                var userName = data.data!.value['userName'];
                var imageUrl = data.data!.value['userImage'];
                return Container(
                  width: double.infinity,
                  height: 60,
                  child: Card(
                    elevation: 10,
                    child: Row(
                      children: [
                        Expanded(child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: TextFormField(
                            controller: textEditingController,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                hintText: 'Type Something..'
                            ),

                          ),
                        )),
                        IconButton(onPressed: (){
                          if(textEditingController.text.isNotEmpty){
                            AuthService().sendMessage(textEditingController.text,userName,imageUrl);
                            textEditingController.text  = '';
                          }
                        }, icon: Icon(Icons.send))
                      ],
                    ),
                  ),
                );
              }
              return Center(
                child: Text(''),
              );
            },
          ),
        )
      ],
    );
  }
}
