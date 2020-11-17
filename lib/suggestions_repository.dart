import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SuggestionsRepository with ChangeNotifier {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth;
  Set<WordPair> _saved;
  User _user;

  SuggestionsRepository.instance()
      : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> addPair(WordPair pair) async {
    _saved.add(pair);
    if (_user != null) {
      await _firestore.collection('users')
          .doc(_user.uid)
          .set({ 'suggestions': _saved.map((pair)=>{'first': pair.first,'second': pair.second}).toList()});
    }
    notifyListeners();
  }

  Future<void> removePair(WordPair pair) async {
    _saved.remove(pair);
    if (_user != null) {
      await _firestore.collection('users')
          .doc(_user.uid)
          .set({ 'suggestions': _saved.map((pair)=>{'first': pair.first,'second': pair.second}).toList()});
    }
    notifyListeners();
  }

  Set<WordPair> get saved => _saved;

  Future<void> _onAuthStateChanged(User firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _saved = new Set<WordPair>();
    } else {
      _user = firebaseUser;

      if (_saved == null) {
        _saved = Set<WordPair>();
      }

      _saved.addAll(await _firestore.collection('users')
                                    .doc(_user.uid)
                                    .get()
                                    .then((doc) => doc.data())
                                    .then((data) => Set.from(data['suggestions'].map((sug) => WordPair(sug['first'],sug['second'])))));
      await _firestore.collection('users')
          .doc(_user.uid)
          .set({ 'suggestions': _saved.map((pair)=>{'first': pair.first,'second': pair.second}).toList()});
    }
    notifyListeners();
  }

}
