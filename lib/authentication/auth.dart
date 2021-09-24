import 'dart:collection';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:language/models/user.dart';
import 'package:language/screens/home.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  /////////////////////////////////////// LOGIN / REGISTRATION ////////////////////////////////////

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  var uuid = Uuid();
  var databaseUrl =
      "https://chatty-ad55d-default-rtdb.europe-west1.firebasedatabase.app/";

  UserModel? getUser(User? user) {
    return user == null ? null : UserModel(userId: user.uid);
  }

  Stream<UserModel> get onStatusChanged {
    return firebaseAuth
        .authStateChanges()
        .map((user) => UserModel(userId: user!.uid));
  }

  Future loginUser(String email, String password, BuildContext context) async {
    try {
      var user = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      getUser(user.user);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  Future registerUser(String email, String password) async {
    try {
      await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);

      print('User Registered');
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String> uploadUserImage(
      File file, String email, String userName, BuildContext context) async {
    Reference reference = FirebaseStorage.instance.ref().child('images');

    TaskSnapshot taskSnapshot = await reference
        .child(firebaseAuth.currentUser!.uid)
        .child(uuid.v1())
        .putFile(file);

    return await taskSnapshot.ref.getDownloadURL();
  }

  Future registerUserDetails(
      String email, String userName, String imageUrl) async {
    final DatabaseReference ref =
        FirebaseDatabase(databaseURL: databaseUrl).reference().child('Users');
    Map<String, dynamic> value = HashMap();

    value['email'] = email;
    value['userName'] = userName;
    value['userImage'] = imageUrl;
    value['status'] = 'online';

    await ref.child(firebaseAuth.currentUser!.uid).set(value);
  }

  Future<DataSnapshot> getUserDetails() async {
    DatabaseReference databaseReference =
        FirebaseDatabase(databaseURL: databaseUrl).reference().child('Users');
    return await databaseReference.child(firebaseAuth.currentUser!.uid).once();
  }

  /////////////////////////////////////////MESSAGES SECTION///////////////////////////////////

  Future sendMessage(String message, String userName, String imageUrl,
      String galleryImage) async {
    DatabaseReference databaseReference =
        FirebaseDatabase(databaseURL: databaseUrl).reference();

    Map<String, dynamic> userMessage = new HashMap();
    userMessage['message'] = message;
    userMessage['userName'] = userName;
    userMessage['imageUrl'] = imageUrl;
    userMessage['userId'] = firebaseAuth.currentUser!.uid;
    userMessage['gallaryImage'] = galleryImage;
    userMessage['time'] = DateTime.now().toString();

    await databaseReference.child('Messages').child(uuid.v1()).set(userMessage);
  }

  Stream<Event?> getMessages() {
    DatabaseReference databaseReference = FirebaseDatabase(databaseURL: databaseUrl)
            .reference()
            .child('Messages');
    return databaseReference.orderByChild('time').onValue;
  }

  Future sendPrivateMessage(
      String message, String userName, String imageUrl, String userId,String currentUserId) async {
    DatabaseReference databaseReference = FirebaseDatabase(databaseURL: databaseUrl).reference().child('private');
    DatabaseReference reference = FirebaseDatabase(databaseURL: databaseUrl).reference().child('lastMessage');

    Map<String, dynamic> userMessage = new HashMap();
    userMessage['message'] = message;
    userMessage['userName'] = userName;
    userMessage['imageUrl'] = imageUrl;
    userMessage['userId'] = currentUserId;
    userMessage['time'] = DateTime.now().toString();

    await databaseReference
        .child('privateMessages')
        .child(currentUserId)
        .child(uuid.v1())
        .set(userMessage);

    await databaseReference
        .child('privateMessages')
        .child(userId)
        .child(uuid.v1())
        .set(userMessage);

    await reference
        .child(userId)
        .child(currentUserId)
        .update(userMessage);
  }

  Stream<Event?> getPrivateMessage() {
    DatabaseReference databaseReference =
        FirebaseDatabase(databaseURL: databaseUrl).reference().child('private');
    return databaseReference
        .child('privateMessages')
        .child(firebaseAuth.currentUser!.uid)
        .orderByChild('time')
        .onValue;
  }

  Stream<Event?> getLastMessage() {
    DatabaseReference databaseReference =
        FirebaseDatabase(databaseURL: databaseUrl)
            .reference()
            .child('lastMessage');
    return databaseReference.child(firebaseAuth.currentUser!.uid).onValue;
  }

  ////////////////////////////////////////////Friends SECTION//////////////////////////////////////

  Future sendFriendRequest(String receiverId, String senderName, String url) {
    DatabaseReference databaseReference =
        FirebaseDatabase(databaseURL: databaseUrl)
            .reference()
            .child('requests');

    Map<String, dynamic> map = new HashMap();
    map['userName'] = senderName;
    map['receiverId'] = receiverId;
    map['status'] = 'pending';
    map['senderId'] = firebaseAuth.currentUser!.uid;
    map['time'] = DateTime.now().toString();
    map['imageUrl'] = url;

    return databaseReference
        .child(receiverId)
        .child(firebaseAuth.currentUser!.uid)
        .set(map);
  }

  Future<DataSnapshot> getFriendRequest() async {
    DatabaseReference databaseReference =
        FirebaseDatabase(databaseURL: databaseUrl)
            .reference()
            .child('requests');
    return databaseReference.child(firebaseAuth.currentUser!.uid).once();
  }

  Future updateFriendRequest(
      String status, String userId, String name, String imageUrl) async {
    DatabaseReference databaseReference =
        FirebaseDatabase(databaseURL: databaseUrl)
            .reference()
            .child('approvals');

    Map<String, dynamic> map = new HashMap();
    map['name'] = name;
    map['status'] = status;
    map['senderId'] = firebaseAuth.currentUser!.uid;
    map['time'] = DateTime.now().toString();
    map['imageUrl'] = imageUrl;

    return databaseReference
        .child(userId)
        .child(firebaseAuth.currentUser!.uid)
        .update(map);
  }

  Future updateCurrentUserFriends(String status, String currentUserId,
      String userId, String name, String imageUrl) async {
    DatabaseReference databaseReference =
        FirebaseDatabase(databaseURL: databaseUrl)
            .reference()
            .child('approvals');

    Map<String, dynamic> map = new HashMap();
    map['name'] = name;
    map['status'] = status;
    map['senderId'] = currentUserId;
    map['time'] = DateTime.now().toString();
    map['imageUrl'] = imageUrl;

    return databaseReference.child(currentUserId).child(userId).update(map);
  }

  Future deleteUserFriendship(String senderId) async {
    print('senderID' + senderId);
    print(firebaseAuth.currentUser!.uid);
    DatabaseReference databaseReference =
        FirebaseDatabase(databaseURL: databaseUrl)
            .reference()
            .child('requests');
    return databaseReference
        .child(firebaseAuth.currentUser!.uid)
        .child(senderId)
        .remove();
  }

  Stream<Event?> getApprovals() {
    DatabaseReference databaseReference =
    FirebaseDatabase(databaseURL: databaseUrl)
        .reference()
        .child('approvals');
    return databaseReference
        .child(firebaseAuth.currentUser!.uid)
        .orderByChild('status')
        .equalTo('accepted')
        .onValue;
  }

  Future uploadImage(PickedFile file) async {
    Reference reference = FirebaseStorage.instance.ref("userImages");

    TaskSnapshot taskSnapshot = await reference
        .child(firebaseAuth.currentUser!.uid)
        .child(uuid.v1())
        .putFile(File(file.path));

    String imageDownloadUrl = await taskSnapshot.ref.getDownloadURL();

    return imageDownloadUrl;
  }

  //////////////////////////////////////////////NOTIFICATION SECTION//////////////////////////////////////////

  Future pushNotification(String name, String userId) async {
    DatabaseReference databaseReference =
        FirebaseDatabase(databaseURL: databaseUrl)
            .reference()
            .child('notifications');

    Map<String, dynamic> notificationMap = new HashMap();
    notificationMap['name'] = name;
    notificationMap['isOpen'] = false;
    notificationMap['time'] = DateTime.now().toString();
    notificationMap['notificationId'] = DateTime.now().millisecondsSinceEpoch;

    await databaseReference.child(userId).child(DateTime.now().millisecondsSinceEpoch.toString()).set(notificationMap);
  }

  Future<DataSnapshot?> getNotifications() async {
    print("notification bloc called");
    DatabaseReference databaseReference = FirebaseDatabase(databaseURL: databaseUrl)
        .reference()
        .child('notifications');
    return  await databaseReference.child(firebaseAuth.currentUser!.uid).once();
  }

  Future updateNotificationStatus(notificationId) async {
    DatabaseReference databaseReference = FirebaseDatabase(databaseURL: databaseUrl).reference().child('notifications');

     databaseReference
        .child(firebaseAuth.currentUser!.uid)
        .child(notificationId)
        .update({'isOpen' : true});
  }

  Future deleteNotification(notificationId) async {
    DatabaseReference databaseReference =   FirebaseDatabase(databaseURL: databaseUrl).reference().child('notifications');
    databaseReference
        .child(firebaseAuth.currentUser!.uid)
        .remove();
  }
}


/*
Stream<Event?> getNotifications() {
    DatabaseReference databaseReference =
        FirebaseDatabase(databaseURL: databaseUrl)
            .reference()
            .child('notifications');
    return databaseReference.child(firebaseAuth.currentUser!.uid).onValue;
  }
*/