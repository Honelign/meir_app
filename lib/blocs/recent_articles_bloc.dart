import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:news_app/models/article.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentBloc extends ChangeNotifier {
  List<Article> _data = [];

  List<Article> get data => _data;
  String? homeSponsor;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future getData() async {
    QuerySnapshot rawData;
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String? _uid = sp.getString('uid');
    String _fieldName = 'read marked items';

    if (_uid != null && _uid.isNotEmpty) {
      final DocumentReference ref =
          FirebaseFirestore.instance.collection('users').doc(_uid);
      DocumentSnapshot snap = await ref.get();
      List d = [];
      try {
        d = snap[_fieldName];
      } catch (e) {
        ref.update({_fieldName: []});
      }
      if (d.isEmpty)
        d.add("someID"); // bcz 'not-in' filters require a non-empty

      rawData = await firestore
          .collection('contents')
          .orderBy('timestamp', descending: true)
          //.where('timestamp', whereNotIn: d) // due to error
          .limit(5)
          .get();
    } else {
      rawData = await firestore
          .collection('contents')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();
    }

    rawData = await firestore
        .collection('contents')
        .orderBy('timestamp', descending: true)
        .limit(5)
        .get();

    List<DocumentSnapshot> _snap = [];
    _snap.addAll(rawData.docs);
    _data = _snap.map((e) => Article.fromFirestore(e)).toList();
    notifyListeners();

    firestore
        .collection('sponsors')
        .doc('homepage_sponsor')
        .get()
        .then((DocumentSnapshot snap) {
      String? _sponsorName = snap['name'];
      homeSponsor = _sponsorName;
      notifyListeners();
    });
  }

  onRefresh() {
    _data.clear();
    getData();
    notifyListeners();
  }
}
