import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return AuthScreenState();
  }
}

class AuthScreenState extends State<AuthScreen>{

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseUser _currentUser;

  Future<GoogleSignInAccount> _handleSignOut() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.disconnect();
    return googleUser;
  }

  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    _currentUser = await _auth.signInWithCredential(credential);
    print("signed in " + _currentUser.displayName);
    return _currentUser;
  }

  void _signin() {
    _handleSignIn()
        .then((FirebaseUser user){
          print(user);
          setState(() {

          });
    }).catchError((e) => print(e));
  }

  void _signout() {
    _handleSignOut().then((GoogleSignInAccount user){
      print(user);
      _currentUser = null;
      setState(() {

      });
    }).catchError((e) => print(e));
  }

  Widget _buildBody() {
    if (_currentUser != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ListTile(
            leading: Image(image: NetworkImage(_currentUser.photoUrl),),
            title: Text(_currentUser.displayName),
            subtitle: Text(_currentUser.email),
          ),
          const Text("Signed in successfully."),
          Text(_currentUser.displayName),
          RaisedButton(
            child: const Text('SIGN OUT'),
            onPressed: _signout,
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text("You are not currently signed in."),
          RaisedButton(
            child: const Text('SIGN IN'),
            onPressed: _signin,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
        ),
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildBody(),
        ));
  }
}