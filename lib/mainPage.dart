import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:collection';

final FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseUser currentUser;
var colorsQueue = new Queue.from(["green", "yellow", "red"]);

class mainPage extends StatelessWidget{

  void getCurrentUser() async {
    currentUser = await _auth.currentUser();
  }

  pickColor(String color){
    if(color == "green"){
      return Colors.green;
    }
    else if(color == "yellow"){
      return Colors.yellow;
    }
    else{
      return Colors.red;
    }
  }


  @override
  Widget build(BuildContext context)  {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Users"),
      ),
      body: new StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('user').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
            if (!snapshot.hasData) return new Text('Loading...');
            return new ListView(
              children: snapshot.data.documents.map((DocumentSnapshot document) {
                return new ListTile(
                  title: new Text(document['username']),
                  trailing: new GestureDetector(
                    child: new Icon(Icons.favorite_border, color: pickColor(document['status']),),
                    onTap: (){
                      Firestore.instance.collection('user').document()
                          .setData({'status':'blue' });
                    },
                  ),
                  subtitle: new Container(
                    margin: EdgeInsets.only(top: 10.0),
                    child: new Divider(),
                  ),
                );
              }).toList(),
            );
          }
      ),
    );
  }

}
