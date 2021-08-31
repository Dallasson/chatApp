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
import 'package:language/models/user.dart';
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

  @override
  Widget build(BuildContext context) {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chat App'),
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
              Tab(text: 'Profile',)
            ],
          ),
        ),
        drawer: Drawer(
          child: SafeArea(
            child:  StreamBuilder<Event?>(
          stream: AuthService().getApprovals(),
          builder: (context,data){
            if(data.hasError){
              return Center(
                child: Text('No friends'),
              );
            }
            if(data.connectionState == ConnectionState.active){
               if(data.data!.snapshot.exists){
                 Map<dynamic,dynamic> map = data.data!.snapshot.value;
                 for(var child in map.values){

                   var status = child['status'];
                   if(status == 'accepted'){
                     var time = child['time'];
                     var name = child['name'];
                     var senderId = child['senderId'];

                     showNotification(name);

                     list.add(NotificationModel(name: name, time: time, status: status, senderId: senderId));

                   }
                   return Column(
                     children: List.generate(list.length, (index){
                       return ListTile(title: Text(list[index].name),);
                     }),
                   );
                 }
               }
            }
            return Center(
              child: Text('No friends'),
            );
          },
        ),
          ),
        ),
        body: TabBarView(
          children: [
            PublicPage(),
            FriendsPage(),
            ProfilePage()
          ],
        ),
      ),
    );
  }
}

