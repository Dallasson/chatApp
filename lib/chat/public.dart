
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:language/authentication/auth.dart';
import 'package:language/chat/private.dart';
import 'package:language/models/message.dart';

class PublicPage extends StatefulWidget {
  const PublicPage({Key? key}) : super(key: key);

  @override
  _PublicPageState createState() => _PublicPageState();
}

class _PublicPageState extends State<PublicPage> {
  var isCurrentUser = true;
  TextEditingController textEditingController = new TextEditingController();

  late List<MessageModel> list = [];
  
  bool isCalledOnce = true;

  String name = '';
  String message = '';
  String imageUrl = '';
  String userId = '';
  String userImage = '';
  String galleryImage = '';

  String currentUserName = '';
  String currentUserImage = '';
  late MessageModel messageModel;

  late ImagePicker imagePicker;

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
  }

  Future<PickedFile?>? uploadImage() async {
    imagePicker = ImagePicker();
    var file = await imagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        PickedFile(file.path);
      });
      return PickedFile(file.path);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
        child: Column(
          children: [
          Expanded(
            child:Container(
              child: StreamBuilder<Event?>(
                stream: AuthService().getMessages(),
                builder: (context, data) {
                  if(data.hasError){
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
                            'No discussions...',
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    );
                  }
                  if (data.connectionState == ConnectionState.active) {
                    list.clear();
                    if (data.data!.snapshot.exists) {
                      Map<dynamic, dynamic> values = data.data!.snapshot.value;
                      for (var child in values.values) {
                        name = child['userName'];
                        message = child['message'] ?? '';
                        imageUrl = child['imageUrl'] ?? '';
                        userId = child['userId'];
                        galleryImage = child['gallaryImage'] ?? '';

                        messageModel = MessageModel(
                            name: name,
                            imageUrl: imageUrl,
                            message: message,
                            userId: userId,
                            gallaryImage: galleryImage);
                        list.add(messageModel);
                      }


                      return ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          print('Id here' + list[index].userId);
                          return Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              child: Row(
                                children: [
                                  Container(
                                    height : 60,
                                    width: 60,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      backgroundImage: NetworkImage(list[index].imageUrl),
                                    ),),
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
                                            style: TextStyle(
                                                fontFamily: 'source',
                                                color: Colors.white),
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
                                  Visibility(
                                    visible: list[index].userId ==
                                        FirebaseAuth.instance.currentUser!.uid
                                        ? false
                                        : true,
                                    child: PopupMenuButton(
                                      color: Color(0xff333652),
                                      icon: Icon(
                                        Icons.more_vert,
                                        color: Colors.white,
                                      ),
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          child: GestureDetector(
                                            child: Text(
                                              'Send Message',
                                              style: TextStyle(
                                                  fontFamily: 'source',
                                                  color: Colors.white),
                                            ),
                                            onTap: () {
                                              if (list[index].userId !=
                                                  FirebaseAuth
                                                      .instance.currentUser!.uid) {
                                                Navigator.pop(context);
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            PrivateChatPage(
                                                                id: list[index]
                                                                    .userId)));
                                              }
                                            },
                                          ),
                                        ),
                                        PopupMenuItem(
                                            child: GestureDetector(
                                              onTap: () {
                                                if (list[index].userId !=
                                                    FirebaseAuth
                                                        .instance.currentUser!.uid) {
                                                  AuthService().sendFriendRequest(
                                                    list[index].userId,
                                                    currentUserName,
                                                    currentUserImage,
                                                  );
                                                  Fluttertoast.showToast(
                                                      msg:
                                                      "A Friend request has been sent");
                                                  Navigator.pop(context);
                                                }
                                              },
                                              child: Text(
                                                'Add Friend',
                                                style: TextStyle(
                                                    fontFamily: 'source',
                                                    color: Colors.white),
                                              ),
                                            ))
                                      ],
                                    ),
                                  )
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
                              'No discussions...',
                              style: TextStyle(color: Colors.white),
                            )
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

                print('Current Image' + currentUserImage);
                return Container(
                  width: double.infinity,
                  height: 60,
                  child: Card(
                    color: Color(0xff333652),
                    elevation: 10,
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () async {
                              PickedFile? file = await uploadImage();
                              if (file != null) {
                                await AuthService().uploadImage(file);
                              }
                              //File(file!.path) != null
                              //upload
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
                            style: TextStyle(color: Colors.white),
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
                                AuthService().sendMessage(textEditingController.text, currentUserName, currentUserImage, userImage);
                                textEditingController.text = '';
                              } else {
                                AuthService().sendMessage('', currentUserName, currentUserImage, userImage);
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
          // Container(
          //   child: StreamBuilder<Event?>(
          //     stream: AuthService().getApprovals(),
          //     builder: (context,stream){
          //       if(stream.connectionState == ConnectionState.active){
          //          if(stream.data!.snapshot.exists){
          //            Map<dynamic,dynamic> map = stream.data!.snapshot.value;
          //            for(var child in map.values){
          //              var senderId = child['senderId'];
          //              var status = child['status'];
          //            }
          //          }
          //       }
          //     },
          //   ),
          // )
      ],
    ));
  }
}
