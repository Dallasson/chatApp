import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:language/authentication/auth.dart';
import 'package:language/chat/friends.dart';
import 'package:language/chat/profile.dart';
import 'package:language/chat/public.dart';
import 'package:language/chat/requests.dart';
import 'package:language/models/notification.dart';
import 'package:language/screens/auth/login.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

   late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
   List<NotificationModel> list = [];

   @override
  void initState() {
    super.initState();

    print('id' + FirebaseAuth.instance.currentUser!.uid);

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var androidInitialization = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitialization = IOSInitializationSettings();

    var initializationSettings = InitializationSettings(
      android: androidInitialization,
      iOS: iosInitialization
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

  }

  void showNotification(String userName){
     var androidNotification = AndroidNotificationDetails(
       'channelID','channelName',"this is friendship notification",
       importance: Importance.max,
       priority: Priority.high,
       showWhen: false
     );

      NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidNotification);
      flutterLocalNotificationsPlugin.show(0, 'Friends Request'
          , userName + 'Has accepted your friends request , get started', platformChannelSpecifics);
  }

  /*
  showNotification(name);
   */
  @override
  Widget build(BuildContext context) {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chat App'),
          backgroundColor: Color(0xFF1b1e44),
          actions: [
            IconButton(onPressed: (){
              AuthService().getUser(null);
              firebaseAuth.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
            }, icon: Icon(Icons.exit_to_app)),
            IconButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => RequestsPage()));
            }, icon: Icon(Icons.chat))
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Public',),
              Tab(text: 'History',),
              Tab(text: 'Profile',),
            ],
          ),
        ),
        drawer: Theme(
          child: Drawer(
            child: SafeArea(
              child:  Column(
                children: [
                  ListTile(title: Text('Friends List',style: TextStyle(fontFamily: 'source'
                      ,fontWeight: FontWeight.bold,color: Colors.white),),),
                 Expanded(child:   StreamBuilder<Event?>(
                   stream: AuthService().getApprovals(),
                   builder: (context,data){
                     list.clear();
                     if(data.hasError){
                       return Center(
                         child: Text('No friends',style: TextStyle(color: Colors.white,fontFamily: 'source'),),
                       );
                     }
                     if(data.connectionState == ConnectionState.active){
                       if(data.data!.snapshot.exists){
                         Map<dynamic,dynamic> map = data.data!.snapshot.value;
                         for(var child in map.values){

                           var time = child['time'];
                           var name = child['name'];
                           var senderId = child['senderId'];
                           var status = child['status'];

                           list.add(NotificationModel(name: name, time: time, status: status, senderId: senderId));

                         }
                         return ListView.builder(
                             itemCount: list.length,
                             itemBuilder: (context,index){
                               return ListTile(title: Text(list[index].name,style: TextStyle(color: Colors.white,
                                   fontFamily: 'source'),));
                             }
                         );
                       }
                     }
                     return Center(
                       child: Text('No friends',style: TextStyle(fontFamily: 'source',color: Colors.white),),
                     );
                   },
                 ),)

                ],
              ),
            ),
          ),
          data: Theme.of(context).copyWith(
            canvasColor: Color(0xFF1b1e44)
          ),
        ),
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
