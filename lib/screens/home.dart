import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:language/authentication/auth.dart';
import 'package:language/chat/friends.dart';
import 'package:language/chat/profile.dart';
import 'package:language/chat/public.dart';
import 'package:language/chat/requests.dart';
import 'package:language/models/friends.dart';
import 'package:language/screens/auth/login.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  List<AcceptedFriendsModel> list = [];

  @override
  void initState() {
    super.initState();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var androidInitialization =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitialization = IOSInitializationSettings();

    var initializationSettings = InitializationSettings(
        android: androidInitialization, iOS: iosInitialization);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    AuthService().getNotifications().then((value)  {
      if(value!.exists){
        Map<dynamic, dynamic> map = value.value;
        for (var child in map.values) {
          var isOpen = child['isOpen'] as bool;
          var notificationId = child['notificationId'];
          var name = child['name'];
          if (isOpen == false) {
            showNotification(name);
            AuthService().updateNotificationStatus(notificationId);
            print("isOpen is equal to false");
          } else {
            AuthService().deleteNotification(notificationId);
            print('isOpen is equal to true');
          }
        }
      }
    });

    AuthService().getApprovals().listen((event) {
      Map<dynamic, dynamic> map = event!.snapshot.value;
      for (var child in map.values) {
        var time = child['time'];
        var name = child['name'];
        var senderId = child['senderId'];
        var status = child['status'];
        var url = child['imageUrl'];

        setState(() {
          list.add(AcceptedFriendsModel(
              name: name,
              time: time,
              status: status,
              senderId: senderId,
              imageUrl: url));
        });
      }
    });
  }

  void showNotification(String userName) {
    var androidNotification = AndroidNotificationDetails(
      'channelID',
      'channelName',
      "this is friendship notification",
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      enableVibration: true,
      onlyAlertOnce: true,
    );

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidNotification);
    flutterLocalNotificationsPlugin.show(0, 'Friends Request', userName + ' Has accepted your friends request , get started',
        platformChannelSpecifics);
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('Taki Eddine',style: TextStyle(fontFamily: 'sf',color: Colors.black54,fontSize: 16),),
          iconTheme: IconThemeData(color: Colors.black54),
          actions: [
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context){
                        return AlertDialog(
                          title: Text('Sign Out',style: TextStyle(fontFamily: 'sf'),),
                          content: Text('Are you sure you want to sign out ?',style: TextStyle(fontFamily: 'sf'),),
                          actions: [
                            Container(
                              decoration : BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: Colors.black38
                              ),
                              child:  FlatButton(onPressed: (){
                                AuthService().getUser(null);
                                firebaseAuth.signOut();
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                              }, child: Text('Yes , Sign out',style: TextStyle(color: Colors.white),),),
                            ),
                            Container(
                              decoration : BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  color: Colors.black38
                              ),
                              child: FlatButton(onPressed: (){
                                Navigator.pop(context);
                              }, child: Text('No , Stay',style: TextStyle(fontFamily: 'sf',color: Colors.white,fontSize: 14),)),
                            )
                          ],
                        );
                      }
                  );
                },
                icon: Icon(Icons.exit_to_app,color: Colors.black38,)),
            IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => RequestsPage()));
                },
                icon: Icon(Icons.chat,color: Colors.black38,))
          ],
          bottom: TabBar(
            indicatorColor: Colors.black26,
            tabs: [
              Tab(
                child: Text("Public",style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold),),
              ),
              Tab(
                child: Text("History",style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold),),
              ),
              Tab(
                child: Text("Profile",style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold),),
              ),
            ],
          ),
        ),
        drawer: Theme(
          child: Drawer(
            child: SafeArea(
              child: Column(
                children: [
                  ListTile(
                    title: Text('Friends List', style: TextStyle(
                          fontFamily: 'source',
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),),),
                   Expanded(
                     child: ListView.builder(
                         itemCount: list.length,
                         itemBuilder: (context, index) {
                           return Padding(
                             padding:
                             const EdgeInsets.only(right: 5, left: 5),
                             child: Container(
                               height: 70,
                               child: Row(
                                 children: [
                                   Container(
                                     decoration: BoxDecoration(
                                         borderRadius:
                                         BorderRadius.circular(10),
                                         shape: BoxShape.rectangle,
                                         border: Border.all(
                                             width: 1.0,
                                             color: Colors.white)),
                                     height: 40,
                                     width: 40,
                                     child: CircleAvatar(
                                       backgroundImage: NetworkImage(
                                           list[index].imageUrl),
                                       backgroundColor: Colors.transparent,
                                     ),
                                   ),
                                   Expanded(
                                       child: ListTile(
                                           title: Text(
                                             list[index].name,
                                             style: TextStyle(
                                                 color: Colors.black38,
                                                 fontWeight: FontWeight.bold,
                                                 fontFamily: 'sf'),
                                           ))),
                                   Padding(
                                     padding:
                                     const EdgeInsets.only(right: 5),
                                     child: Container(
                                       height: 10,
                                       width: 10,
                                       decoration: BoxDecoration(
                                         shape: BoxShape.circle,
                                         color: Colors.green,
                                       ),
                                     ),
                                   )
                                 ],
                               ),
                             ),
                           );
                         }),
                   )
                ],
              ),
            ),),
          data: Theme.of(context).copyWith(canvasColor:Colors.white),),
        body: TabBarView(
          children: [
            PublicPage(),
            FriendsPage(),
            ProfilePage(),
          ],
        ),
      ),
    );
  }
}

 //  Expanded(
 //                    child: StreamBuilder<Event?>(
 //                      stream: AuthService().getApprovals(),
 //                      builder: (context, data) {
 //                        list.clear();
 //                        if (data.hasError) {
 //                          return Center(
 //                            child: Text(
 //                              'No friends',
 //                              style: TextStyle(
 //                                  color: Colors.white, fontFamily: 'source'),
 //                            ),
 //                          );
 //                        }
 //                        if (data.connectionState == ConnectionState.active) {
 //                          if (data.data!.snapshot.exists) {
 //                            Map<dynamic, dynamic> map = data.data!.snapshot.value;
 //                            for (var child in map.values) {
 //                              var time = child['time'];
 //                              var name = child['name'];
 //                              var senderId = child['senderId'];
 //                              var status = child['status'];
 //                              var url = child['imageUrl'];
 //
 //                              list.add(AcceptedFriendsModel(
 //                                  name: name,
 //                                  time: time,
 //                                  status: status,
 //                                  senderId: senderId,
 //                                  imageUrl: url));
 //                            }
 //
 //                          }
 //                        }
 //                        return Center(
 //                          child: Text(
 //                            'No friends',
 //                            style: TextStyle(
 //                                fontFamily: 'source', color: Colors.white),
 //                          ),
 //                        );
 //                      },
 //                    ),
 //                  )
 // */
 //
