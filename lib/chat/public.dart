import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

  var isCurrentUser = false;
  TextEditingController textEditingController = new TextEditingController();

   late List<MessageModel> list = [];

   String name ='';
   String message = '';
   String imageUrl = '';
   String userId = '';

   String currentUserName = '';
   late MessageModel messageModel;

  late Stream<Event?> stream;

  @override
  void initState() {
    super.initState();
    stream = AuthService().getMessages();
    print('Current User ' + FirebaseAuth.instance.currentUser!.uid);

  }

  @override
  Widget build(BuildContext context) {
    list.clear();
    return Container(
      child: Column(
        children: [
          Expanded(child: Container(
            child: StreamBuilder<Event?>(
              stream: stream,
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
                                        Text(list[index].name,style: TextStyle(fontFamily: 'source',color: Colors.white),),
                                        SizedBox(height: 3,),
                                        Container(
                                          color : Colors.black12,
                                          child : Text(list[index].message,style: TextStyle(color: Colors.white),),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: true,
                                  child:  PopupMenuButton(
                                    color: Color(0xff333652),
                                    icon: Icon(Icons.more_vert,color: Colors.white,),
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        child: GestureDetector(
                                          child: Text('Send Message',style: TextStyle(fontFamily: 'source',color: Colors.white),),
                                          onTap: (){
                                            if(list[index].userId != FirebaseAuth.instance.currentUser!.uid){
                                              Navigator.pop(context);
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => PrivateChatPage(
                                                  id : list[index].userId
                                              )));
                                            }
                                          },
                                        ),
                                      ),
                                      PopupMenuItem(
                                          child: GestureDetector(
                                            onTap: (){
                                              if(list[index].userId != FirebaseAuth.instance.currentUser!.uid){
                                                AuthService().sendFriendRequest(list[index].userId, currentUserName);
                                                Fluttertoast.showToast(msg: "A Friend request has been sent");
                                                Navigator.pop(context);
                                              }
                                            },
                                            child: Text('Add Friend',style: TextStyle(fontFamily: 'source',color: Colors.white),),
                                          )
                                      )
                                    ],
                                  ),
                                )
                              ],
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
                  child: Text(''),
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
                  currentUserName = data.data!.value['userName'];
                  var imageUrl = data.data!.value['userImage'];

                  print('this is ' + currentUserName);
                  return Container(
                    width: double.infinity,
                    height: 60,
                    child: Card(
                      color: Color(0xff333652),
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
                                hintText: 'Type Something..',
                                hintStyle: TextStyle(fontStyle: FontStyle.italic,color: Colors.white)
                              ),
                            ),
                          )),
                          IconButton(onPressed: (){
                            if(textEditingController.text.isNotEmpty){
                              AuthService().sendMessage(textEditingController.text,currentUserName,imageUrl);
                              textEditingController.text  = '';
                            }
                          }, icon: Icon(Icons.send,color: Colors.white,))
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
          ),
        ],
      )
    );
  }
}

















