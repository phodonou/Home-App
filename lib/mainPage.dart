import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:collection';

final FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseUser currentUser;
var colorsQueue = new Queue.from(["yellow", "red","green"]);

class mainPage extends StatelessWidget{

  String chooseDoc(){
    String col = colorsQueue.removeLast();
    colorsQueue.addFirst(col);
    return col;
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

  statusChanged () async {
    final funcUrl = "https://us-central1-home-30b1a.cloudfunctions.net/statusChanged";
    try{
      await http.get(funcUrl);
      debugPrint("SUUUUCCCCEDDED");
    }
    catch(e){
      debugPrint("FAIILLLED");
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
                  title: new Text(
                      document['username'],
                      style: new TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold ),
                  ),
                  trailing: new Row(
                    children: <Widget>[
                      new GestureDetector(
                        child: new Icon(Icons.favorite_border,
                          color: pickColor(document['status']),
                          size: 40.0,),
                        onTap: (){
                          Firestore.instance.collection('user').document(document.documentID)
                              .updateData({'status':chooseDoc()});
                        },
                      ),

                      new Container(
                        child: new RaisedButton(
                          onPressed: (){
                            statusChanged();
                          },
                          color: Colors.lightBlueAccent,
                          child: new Text("Notify"),
                        ),
                        margin: EdgeInsets.only(left: 30.0),
                      )
                    ],
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
