import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
FirebaseUser user;

class signUpPage extends StatefulWidget{
  createState() => new signUpPageState();
}

class signUpPageState extends State<signUpPage>{
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final emailController = new TextEditingController();
  final passwordController = new TextEditingController();
  final usernameController = new TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }


  Widget build(BuildContext context) {

    Widget UsernameTextField = new TextFormField(
      keyboardType: TextInputType.emailAddress, //email address just to prevent auto-capitalization
      controller: usernameController,
      decoration: new InputDecoration(
        hintText: "Username",
      ),
      validator: (value){
        if (value.isEmpty){
          return "Please Enter Some text";
        }
      },
    );

    Widget EmailTextField = new Container(
      child: new TextFormField(
        keyboardType: TextInputType.emailAddress, //email address just to prevent auto-capitalization
        controller: emailController,
        decoration: new InputDecoration(
          hintText: "Email",
        ),
        validator: (value){
          if (value.isEmpty){
            return "Please Enter Some text";
          }
        },
      ),
    );

    Widget PasswordTextField = new TextFormField(
      obscureText: true,
      keyboardType: TextInputType.emailAddress, //email address just to prevent auto-capitalization
      controller: passwordController,
      decoration: new InputDecoration(
        hintText: "Password",
      ),
      validator: (value){
        if (value.isEmpty){
          return "Please Enter Some text";
        }
      },
    );

    Widget TextInputs = new Container(
      child: new Column(
        children: <Widget>[ EmailTextField, PasswordTextField],
      ),
      margin: EdgeInsets.only(bottom: 100.0),
    );

    Widget SubmitButton = new Center(
      child: new Row(
          children: <Widget>[new Expanded(
              child: new InkWell(
                onTap: () async {
                  final email = emailController.text;
                  final password = passwordController.text;
                  final username = usernameController.text;
                  if (_formKey.currentState.validate()){
                    _scaffoldKey.currentState.showSnackBar(
                        new SnackBar(duration: new Duration(seconds: 10), content:
                        new Row(
                          children: <Widget>[
                            new CircularProgressIndicator(),
                            new Text("  Creating Account...")
                          ],
                        ),
                        ));
                    try{ //try to sign in user
                      final user = await _auth.createUserWithEmailAndPassword(email: email, password: password); //wait until this completes
                      await Firestore.instance.collection('user').document()
                        .setData({'username':username, 'status':'green' });
                      _firebaseMessaging.subscribeToTopic("all");
                      Navigator.popUntil(context, (_) => !Navigator.canPop(context));
                      Navigator.pushReplacementNamed(context, '/main');
                    }
                    catch(e){ // user login failed
                      final snackBarFail = new SnackBar(content: new Text("Account Creation Failed"),
                        duration: new Duration(seconds: 10), );
                      _scaffoldKey.currentState.removeCurrentSnackBar();
                      _scaffoldKey.currentState.showSnackBar(snackBarFail);

                    }
                  }
                },
                child: new Container(
                  height: 50.0,
                  decoration: new BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: new BorderRadius.circular(10.0),
                  ),
                  child: new Center(child: new Text('Sign Up', style: new TextStyle(fontSize: 18.0, color: Colors.white),),),
                  margin: EdgeInsets.only(bottom: 50.0),
                ),
              )
          )
            ,]
      ),

    );



    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text("Sign Up!"),
      ),
      body: new Form(
          key: _formKey,
          child: new Container(
            child: new ListView(
              children: <Widget>[
                UsernameTextField,
                TextInputs,
                SubmitButton
              ],
            ),
            margin: EdgeInsets.only(top: 200.0),
          )),
    );

  }
}