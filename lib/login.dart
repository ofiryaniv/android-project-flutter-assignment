
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/user_repository.dart';
import 'package:provider/provider.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';


class Login extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final globalKey = GlobalKey<ScaffoldState>();
    TextEditingController _email = TextEditingController(text: "");
    TextEditingController _password = TextEditingController(text: "");
    TextEditingController _confirmation = TextEditingController(text: "");
    bool _validate = true;

    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
          child: Column(children: [
            Padding(padding: EdgeInsets.all(8.0)),
            Text(
                'Welcome to Startup Names Generator, please log in below',
                textAlign: TextAlign.center,
                textScaleFactor: 1.5),
            Padding(padding: EdgeInsets.all(16.0)),
            TextField(
                decoration: InputDecoration(border: InputBorder.none, hintText: 'Email'),
                controller: _email,
            ),
            Divider(),
            TextField(
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: 'Password'),
                controller: _password,
            ),
            Divider(),
            Padding(padding: EdgeInsets.all(8.0)),
            Consumer(
              builder: (context, UserRepository user, _) {
                if(user.status == Status.Authenticating) {
                  return CircularProgressIndicator();
                } else {
                  return Column(
                    children: [
                      RaisedButton(
                        color: Colors.red,
                        onPressed: () async {
                          if (!await user.signIn(_email.text, _password.text)) {
                            globalKey.currentState.showSnackBar(
                                SnackBar(content: Text("Wrong Password")));
                          }
                          else {
                            Navigator.pop(context);
                          }
                        },
                        child: Text('Log in',
                            style: TextStyle(color: Colors.white, fontSize: 20))
                    ),
                      RaisedButton(
                          color: Colors.teal[400],
                          onPressed: () async {
                            showMaterialModalBottomSheet(
                              context: context,
                              builder: (context) => Container(
                                height: 200,
                                child: Column(
                                  children: [
                                    Padding(padding: EdgeInsets.all(10.0)),
                                    Center(child: Text("Please confirm your password below:")),
                                    Row(
                                      children: [
                                        Padding(padding: EdgeInsets.all(5.0))]),
                                    TextField(
                                        controller: _confirmation,
                                        decoration: InputDecoration(
                                          border: InputBorder.none, hintText: 'Password', errorText: _validate ? null : 'Passwords must match')),
                                    Divider(),
                                    RaisedButton(
                                        color: Colors.teal[400],
                                        onPressed: () async {
                                          if(_confirmation.text == _password.text) {
                                            await user.signUp(_email.text,_password.text);
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          } else {
                                            _validate = false;
                                          }
                                        },
                                        child: Text('Confirm',
                                            style: TextStyle(color: Colors.white, fontSize: 20)),
                                    )
                                  ],
                                ),
                              )
                            );
                          },
                          child: Text('New user? Click to sign up',
                              style: TextStyle(color: Colors.white, fontSize: 20))
                      ),]
                  );
                }
              }
            ),
          ]),
          padding: EdgeInsets.all(16.0)),
    );
  }
}