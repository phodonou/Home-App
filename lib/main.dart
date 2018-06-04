import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'mainPage.dart';
import 'signUpPage.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
var phonePrefs;
FirebaseUser user;

void main() => runApp(
    new MyApp()
);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Home',
      theme: new ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: new Scaffold(
        appBar: new AppBar(
          title: new  Text("Home App"),

        ),
        body: new MyForm(),
        key: _scaffoldKey,
      ),
      routes:{
        '/main': (BuildContext context) => new mainPage(),
        '/signUp': (BuildContext context) => new signUpPage(),
        },
    );
  }
}

class MyForm extends StatefulWidget{

  createState() => new MyFormState();
}

class MyFormState extends State<MyForm>{
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final emailController = new TextEditingController();
  final passwordController = new TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

    shouldLoginUser(){
      final future = SharedPreferences.getInstance();
      future.then((prefs) async {
        phonePrefs = prefs;
        if ( !(prefs.getString('email') == null && prefs.getString('password') == null) ){
          try {
            _scaffoldKey.currentState.showSnackBar(
                new SnackBar(duration: new Duration(seconds: 10), content:
                new Row(
                  children: <Widget>[
                    new CircularProgressIndicator(),
                    new Text("  Signing-In...")
                  ],
                ),
                ));
            await _auth.signInWithEmailAndPassword(
                email: prefs.getString('email'),
                password: prefs.getString('password'));
            Navigator.pushReplacementNamed(context, '/main');
          }
          catch(e){
            final snackBarFail = new SnackBar(content: new Text("Login Failed"), );
            _scaffoldKey.currentState.removeCurrentSnackBar();
            _scaffoldKey.currentState.showSnackBar(snackBarFail);
          }
        }
      });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message){

      }
    );
    _firebaseMessaging.requestNotificationPermissions();
  }

  @override
  Widget build(BuildContext context) {

    shouldLoginUser();

    Widget EmailTextField = new Container(
      margin: EdgeInsets.only(bottom: 30.0),
      child: new TextFormField(
        keyboardType: TextInputType.emailAddress,
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

    Widget LoginButton = new Center(
      child: new Row(
        children: <Widget>[new Expanded(
            child: new InkWell(
              onTap: () async {
                final email = emailController.text;
                final password = passwordController.text;
                if (_formKey.currentState.validate()){
                  _scaffoldKey.currentState.showSnackBar(
                      new SnackBar(duration: new Duration(seconds: 10), content:
                      new Row(
                        children: <Widget>[
                          new CircularProgressIndicator(),
                          new Text("  Signing-In...")
                        ],
                      ),
                      ));
                  try{ //try to sign in user
                    final user = await _auth.signInWithEmailAndPassword(email: email, password: password); //wait until this completes
                    await phonePrefs.setString('email', email);
                    await phonePrefs.setString('password', password);
                    Navigator.pushReplacementNamed(context, '/main');
                  }
                  catch(e){ // user login failed
                    final snackBarFail = new SnackBar(content: new Text("Login Failed"), );
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
                child: new Center(child: new Text('Login', style: new TextStyle(fontSize: 18.0, color: Colors.white),),),
                margin: EdgeInsets.only(bottom: 50.0),
              ),
            )
        )
    ,]
      ),

    );

    Widget LoginInputs = new Container(
          child: new Column(
            children: <Widget>[EmailTextField, PasswordTextField],
          ),
          margin: EdgeInsets.only(top: 100.0, bottom: 50.0),
        );

    return new Form(
      key: _formKey,
      child: new ListView(
        children: <Widget>[
          LoginInputs,
          LoginButton,
          new Center(child:
            new GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/signUp');
              },
              child:  new Text( "Create Account",
                style: new TextStyle(fontSize: 20.0),) ,
            )
          )
        ],
      )
    );
  }
}