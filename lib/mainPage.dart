import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class mainPage extends StatefulWidget{
  createState() => new mainPageState();
}

class mainPageState extends State<mainPage>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Main Page"),
      ),
      body: new Text("Progress has been made"),
    );
  }
}