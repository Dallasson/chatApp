import 'dart:collection';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:language/models/user.dart';
import 'package:language/screens/home.dart';
import 'package:uuid/uuid.dart';


class AuthService {

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  var uuid = Uuid();
  var databaseUrl = "https://chatty-ad55d-default-rtdb.europe-west1.firebasedatabase.app/";

  UserModel? getUser(User? user){
    return user == null ? null : UserModel(userId: user.uid);
  }

  Stream<UserModel> get onStatusChanged {
    return firebaseAuth.authStateChanges().map((user) => UserModel(userId: user!.uid));
  }

  Future loginUser(String email , String password,BuildContext context) async {
     try{

      var user =  await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

       getUser(user.user);

       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));


     }on FirebaseAuthException catch (e) {
       if (e.code == 'weak-password') {
         print('The password provided is too weak.');
       } else if (e.code == 'email-already-in-use') {
         print('The account already exists for that email.');
       }
     } catch (e) {
       print(e);
     }
  }

  Future registerUser(String email,String password,String userName,File file,BuildContext context) async {
    try{
       await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

       print('User Registered');
       uploadUserImage(file,email,userName,context);
    }catch(e){
      print(e.toString());
    }
  }

  Future uploadUserImage(File file,String email , String userName, BuildContext context) async {

    Reference reference = FirebaseStorage.instance.ref().child('images');

    TaskSnapshot taskSnapshot =  await reference.child(firebaseAuth.currentUser!.uid).child(uuid.v1()).putFile(file);

    var imageUrl = await taskSnapshot.ref.getDownloadURL();

    print("Image Uploaded");

    registerUserDetails(email,userName,imageUrl,context);
  }

  Future registerUserDetails(String email,String userName,String imageUrl,BuildContext context)  async {

    final DatabaseReference ref = FirebaseDatabase(databaseURL: databaseUrl).reference().child('Users');
    Map<String,dynamic> value = HashMap();

    value['email'] = email;
    value['userName'] =  userName;
    value['userImage'] = imageUrl;

    await ref.child(firebaseAuth.currentUser!.uid).set(value);

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  Future<DataSnapshot> getUserDetails() async {
    DatabaseReference databaseReference = FirebaseDatabase(databaseURL: databaseUrl).reference().child('Users');
    return await databaseReference.child(firebaseAuth.currentUser!.uid).once();
  }

  Future sendMessage(String message,String userName, String imageUrl) async {
    DatabaseReference databaseReference = FirebaseDatabase(databaseURL: databaseUrl).reference();

    Map<String,dynamic> userMessage = new HashMap();
    userMessage['message'] = message;
    userMessage['userName'] = userName;
    userMessage['imageUrl'] = imageUrl;
    userMessage['userId'] = firebaseAuth.currentUser!.uid;

    await databaseReference.child('Messages').child(uuid.v1()).set(userMessage);
  }

  Stream<Event?> getMessages() {
    DatabaseReference databaseReference = FirebaseDatabase(databaseURL: databaseUrl).reference().child('Messages');
    return  databaseReference.onValue;
  }

  Future sendPrivateMessage(String message , String userName, String imageUrl , String userId) async {
    DatabaseReference databaseReference = FirebaseDatabase(databaseURL: databaseUrl).reference().child('private');
    DatabaseReference reference = FirebaseDatabase(databaseURL: databaseUrl).reference().child('lastMessage');

    Map<String,dynamic> userMessage = new HashMap();
    userMessage['message'] = message;
    userMessage['userName'] = userName;
    userMessage['imageUrl'] = imageUrl;

    await databaseReference.child('privateMessages').child(firebaseAuth.currentUser!.uid).child(uuid.v1()).set(userMessage);
    await databaseReference.child('privateMessages').child(userId).child(uuid.v1()).set(userMessage);
    await reference.child(userId).child(firebaseAuth.currentUser!.uid).update(userMessage);

  }

  Stream<Event?> getPrivateMessage() {
    DatabaseReference databaseReference = FirebaseDatabase(databaseURL: databaseUrl).reference().child('private');
    return databaseReference.child('privateMessages').child(firebaseAuth.currentUser!.uid).onValue;
  }

  Stream<Event?> getLastMessage(){
    DatabaseReference databaseReference = FirebaseDatabase(databaseURL: databaseUrl).reference().child('lastMessage');
    return databaseReference.child(firebaseAuth.currentUser!.uid).onValue;
  }

  Future sendFriendRequest(String receiverId,String senderName){
    DatabaseReference databaseReference = FirebaseDatabase(databaseURL: databaseUrl).reference().child('requests');

    Map<String,dynamic> map = new HashMap();
    map['userName'] = senderName;
    map['status'] = 'pending';
    map['senderId'] = firebaseAuth.currentUser!.uid;
    map['time'] = DateTime.now().toString();

    return databaseReference.child(receiverId).child(firebaseAuth.currentUser!.uid).set(map);
  }

  Future<DataSnapshot> getFriendRequest() async {
    DatabaseReference databaseReference = FirebaseDatabase(databaseURL: databaseUrl).reference().child('requests');
    return databaseReference.child(firebaseAuth.currentUser!.uid).once();
  }

  Future updateFriendRequest(String status ,String userId,String name) async {
    DatabaseReference databaseReference = FirebaseDatabase(databaseURL: databaseUrl).reference().child('approvals');

    Map<String,dynamic> map = new HashMap();
    map['name'] = name;
    map['status'] =  status;
    map['senderId'] = firebaseAuth.currentUser!.uid;
    map['time'] = DateTime.now().toString();

    deleteUserRequest(userId);

    return databaseReference.child(userId).child(firebaseAuth.currentUser!.uid).update(map);
  }

  Future deleteUserRequest(String senderId) async {
    DatabaseReference databaseReference = FirebaseDatabase(databaseURL: databaseUrl).reference().child('requests');
    return databaseReference.child(senderId).child(firebaseAuth.currentUser!.uid).remove();
  }
}