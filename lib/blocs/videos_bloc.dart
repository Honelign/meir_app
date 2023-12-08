import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:news_app/models/article.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideosBloc extends ChangeNotifier {

  DocumentSnapshot? _lastVisible;
  DocumentSnapshot? get lastVisible => _lastVisible;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<Article> _data = [];
  List<Article> get data => _data;

  String _popSelection = 'recent';
  String get popupSelection => _popSelection;


  List<DocumentSnapshot> _snap = [];
  final FirebaseFirestore firestore = FirebaseFirestore.instance;


  bool? _hasData;
  bool? get hasData => _hasData;




  Future<Null> getData(mounted, String orderBy) async {
    _hasData = true;
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
            .where('content type', isEqualTo: 'video')
            .where('timestamp', whereNotIn: d)
            .orderBy(orderBy, descending: true)
            .limit(6)
            .get();
      else
        rawData = await firestore
            .collection('contents')
            .where('content type', isEqualTo: 'video')
            .where('timestamp', whereNotIn: d)
            .orderBy(orderBy, descending: true)
            .startAfter([_lastVisible![orderBy]])
            .limit(6)
            .get();
    } else {
      if (_lastVisible == null)
        rawData = await firestore
            .collection('contents')
            .where('content type', isEqualTo: 'video')
            .orderBy(orderBy, descending: true)
            .limit(6)
            .get();
      else
        rawData = await firestore
            .collection('contents')
            .where('content type', isEqualTo: 'video')
            .orderBy(orderBy, descending: true)
            .startAfter([_lastVisible![orderBy]])
            .limit(6)
            .get();
    }

    if (rawData.docs.length > 0) {
      _lastVisible = rawData.docs[rawData.docs.length - 1];
      if (mounted) {
        _isLoading = false;
        _snap.addAll(rawData.docs);
        _data = _snap.map((e) => Article.fromFirestore(e)).toList();
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

    notifyListeners();
    return null;
  }


  afterPopSelection (value, mounted, orderBy){
    _popSelection = value;
    onRefresh(mounted, orderBy);
    notifyListeners();
  }



  setLoading(bool isloading) {
    _isLoading = isloading;
    notifyListeners();
  }




  onRefresh(mounted, orderBy) {
    _isLoading = true;
    _snap.clear();
    _data.clear();
    _lastVisible = null;
    getData(mounted, orderBy);
    notifyListeners();
  }


}