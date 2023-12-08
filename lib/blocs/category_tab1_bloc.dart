import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:news_app/models/article.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryTab1Bloc extends ChangeNotifier{
  
  List<Article> _data = [];
  List<Article> get data => _data;
  String? category1Sponsor;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _snap = [];

  DocumentSnapshot? _lastVisible;
  DocumentSnapshot? get lastVisible => _lastVisible;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool? _hasData;
  bool? get hasData => _hasData;


  Future<Null> getData(mounted, String category) async {
    QuerySnapshot rawData;
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String? _uid = sp.getString('uid');
    String _fieldName = 'read marked items';

    if (_uid != null && _uid.isNotEmpty) {
      final DocumentReference ref = FirebaseFirestore.instance.collection(
          'users').doc(_uid);
      DocumentSnapshot snap = await ref.get();
      List d = [];
      try {
        d = snap[_fieldName];
      } catch (e) {
        await ref.update({_fieldName: []});
      }
      if (d.isEmpty) d.add(
          "someID"); // bcz 'not-in' filters require a non-empty

      if (_lastVisible == null)
        rawData = await firestore
            .collection('contents')
            .where('category', isEqualTo: category)
            .where('timestamp', whereNotIn: d)
            .orderBy('timestamp', descending: true)
            .limit(5)
            .get();
      else
        rawData = await firestore
            .collection('contents')
            .where('category', isEqualTo: category)
            .where('timestamp', whereNotIn: d)
            .orderBy('timestamp', descending: true)
            .startAfter([_lastVisible!['timestamp']])
            .limit(5)
            .get();
    } else {
      if (_lastVisible == null)
        rawData = await firestore
            .collection('contents')
            .where('category', isEqualTo: category)
            .orderBy('timestamp', descending: true)
            .limit(5)
            .get();
      else
        rawData = await firestore
            .collection('contents')
            .where('category', isEqualTo: category)
            .orderBy('timestamp', descending: true)
            .startAfter([_lastVisible!['timestamp']])
            .limit(5)
            .get();
    }

    if (rawData.docs.length > 0) {
      _lastVisible = rawData.docs[rawData.docs.length - 1];
      if (mounted) {
        _isLoading = false;
        _snap.addAll(rawData.docs);
        _data = _snap.map((e) => Article.fromFirestore(e)).toList();
        notifyListeners();
      }
    } else {

      if(_lastVisible == null){

        _isLoading = false;
        _hasData = false;
        print('no items');

      }else{
        _isLoading = false;
        _hasData = true;
        print('no more items');
      }
      
    }

    firestore.collection('sponsors').doc('category1_sponsor').get().then((DocumentSnapshot snap) {
      String? _sponsorName = snap['name'];
      category1Sponsor = _sponsorName;
      notifyListeners();
    });

    notifyListeners();
    return null;
  }


  



  setLoading(bool isloading) {
    _isLoading = isloading;
    notifyListeners();
  }




  onRefresh(mounted, String category) {
    _isLoading = true;
    _snap.clear();
    _data.clear();
    _lastVisible = null;
    getData(mounted, category);
    notifyListeners();
  }



}