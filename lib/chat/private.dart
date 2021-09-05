import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:language/authentication/auth.dart';
import 'package:language/models/private.dart';
import 'package:provider/provider.dart';

class PrivateChatPage extends StatefulWidget {
  String id;
  PrivateChatPage({Key? key, required this.id}) : super(key: key);

  @override
  _PrivateChatPageState createState() => _PrivateChatPageState();
}

class _PrivateChatPageState extends State<PrivateChatPage> {
  TextEditingController textEditingController = new TextEditingController();

  List<PrivateModel> list = [];
  String currentUserName = '';
  String currentUserImage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1b1e44),
        title: Text('Private Chat'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder<Event?>(
            stream: AuthService().getPrivateMessage(),
            builder: (context, data) {
              if (data.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/error.png',
                        height: 70,
                        width: 70,
                        color: Colors.white,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Nothing Found',
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                );
              }
              if (data.connectionState == ConnectionState.active) {
                list.clear();
                if (data.data!.snapshot.exists) {
                  Map<dynamic, dynamic> map = data.data!.snapshot.value;
                  for (var child in map.values) {
                    var name = child['userName'];
                    var message = child['message'];
                    var imageUrl = child['imageUrl'];
                    var userId = child['userId'];

                    list.add(PrivateModel(
                        name: name,
                        imageUrl: imageUrl,
                        message: message,
                        userId: userId));
                  }
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          height: 60,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.transparent,
                                backgroundImage:
                                    NetworkImage(list[index].imageUrl),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        list[index].name,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Container(
                                        color: Colors.black12,
                                        child: Text(
                                          list[index].message,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/error.png',
                          height: 70,
                          width: 70,
                          color: Colors.white,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Nothing Found',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  );
                }
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/error.png',
                      height: 70,
                      width: 70,
                      color: Colors.white,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Nothing Found',
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              );
            },
          )),
          Container(
            height: 60,
            child: FutureBuilder<DataSnapshot>(
              future: AuthService().getUserDetails(),
              builder: (context, data) {
                if (data.hasError) {
                  return Center(
                    child: Text(''),
                  );
                }
                if (data.connectionState == ConnectionState.done) {
                  currentUserName = data.data!.value['userName'];
                  currentUserImage = data.data!.value['userImage'];
                  return Container(
                    width: double.infinity,
                    height: 60,
                    child: Card(
                      color: Color(0xff333652),
                      elevation: 10,
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                if (textEditingController.text.isNotEmpty) {
                                  AuthService().sendPrivateMessage(
                                      textEditingController.text,
                                      currentUserName,
                                      currentUserImage,
                                      widget.id);
                                  textEditingController.text = '';
                                }
                              },
                              icon: Icon(
                                Icons.add_a_photo,
                                color: Colors.white,
                              )),
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: TextFormField(
                              controller: textEditingController,
                              style: TextStyle(
                                color: Colors.white
                              ),
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  hintText: 'Type Something..',
                                  hintStyle: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.white)),
                            ),
                          )),
                          IconButton(
                              onPressed: () {
                                if (textEditingController.text.isNotEmpty) {
                                  AuthService().sendPrivateMessage(
                                      textEditingController.text,
                                      currentUserName,
                                      currentUserImage,
                                      widget.id);
                                  textEditingController.text = '';
                                }
                              },
                              icon: Icon(
                                Icons.send,
                                color: Colors.white,
                              ))
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
      ),
    );
  }
}
