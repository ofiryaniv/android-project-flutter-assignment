import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/user_repository.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class ProfileContent extends StatefulWidget {
  final UserRepository userRepo;
  final BuildContext context;

  ProfileContent({
    @required this.userRepo,
    @required this.context,
    Key key
  }) : super(key: key);

  @override
  _ProfileContentState createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  final picturePicker = ImagePicker();
  String _url;
  bool _loadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _url = widget.userRepo.user.photoURL;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserRepository>(context);
    return Container(
        color: Colors.white,
        child: ListView(children: [
          Column(children: [
            Padding(padding: const EdgeInsets.all(15)),
            Row(
              children: [
                Padding(padding: const EdgeInsets.all(16)),
                _avatar(),
                Padding(padding: const EdgeInsets.all(16)),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    "${user.user.email}",
                    style: TextStyle(fontSize: 20),
                  ),
                  Padding(padding: const EdgeInsets.all(5)),
                  RaisedButton(
                      onPressed: () => _changeAvatar(user),
                      color: Colors.teal[400],
                      child: Text("Change avatar",style: TextStyle(color: Colors.white),))
                ]),
              ],
            )
          ]),
        ]));
  }

  Widget _avatar() {
    if (_loadingAvatar) {
      return Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
          child: CircularProgressIndicator());
    }
    if (_url == null) {
      return Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
      );
    }
    return ClipOval(
        child: Image.network(
      _url,
      fit: BoxFit.cover,
      width: 60,
      height: 60,
    ));
  }

  Future<void> _changeAvatar(UserRepository user) async {
    final chosen = await picturePicker.getImage(source: ImageSource.gallery);
    if (chosen == null) {
      Scaffold.of(widget.context).showSnackBar(
        SnackBar(content: Text('No image selected'))
      );
      return;
    }
    setState(() {
      _loadingAvatar = true;
    });
    final url = await user.changeAvatar(File(chosen.path));
    setState(() {
      _loadingAvatar = false;
      _url = url;
    });
  }
}
