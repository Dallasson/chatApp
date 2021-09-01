import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:language/authentication/auth.dart';
import 'package:language/models/message.dart';
import 'package:language/models/private.dart';
import 'package:provider/provider.dart';

class PrivateChatPage extends StatefulWidget {
  String id;
  PrivateChatPage({Key? key,required this.id}) : super(key: key);

  @override
  _PrivateChatPageState createState() => _PrivateChatPageState();
}

class _PrivateChatPageState extends State<PrivateChatPage> {

  TextEditingController textEditingController = new TextEditingController();

  List<PrivateModel> list = [];

  @override
  Widget build(BuildContext context) {
    Provider.of<Event?>(context);
    list.clear();
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
                      Map<dynamic,dynamic> map = data.data!.snapshot.value;
                      for(var child in map.values){
                        var  name = child['userName'];
                        var message = child['message'];
                        var imageUrl = child['imageUrl'];
                        var userId = child['userId'];

                        list.add(PrivateModel(name: name, imageUrl: imageUrl, message: message,userId: userId));
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
                          );
                        },
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
                              AuthService().sendPrivateMessage(textEditingController.text,userName,imageUrl,widget.id);
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
          ),
        ],
      ),
    );
  }
}
