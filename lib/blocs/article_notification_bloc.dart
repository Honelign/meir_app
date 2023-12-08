import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:news_app/models/article.dart';

class ArticleNotificationBloc extends ChangeNotifier {
  
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<DocumentSnapshot> _snap = [];

  List<Article> _data = [];
  List<Article> get data => _data;

  bool? _hasData;
  bool? get hasData => _hasData;

/*
  Future<List> getNotificationsList() async {
    final DocumentReference ref = firestore.collection('notifications').doc('contents');
    DocumentSnapshot snap = await ref.get();
    if (snap.exists == true) {
      List notificationsList = snap['list'] ?? [];
      //return notificationsList;
      if(notificationsList.isNotEmpty){
        final idsBy10 = [
          for (var i = 0; i < notificationsList.length; i += 10)
            notificationsList.sublist(i, min(i + 10, notificationsList.length))
        ];
        return idsBy10;
      }else{
        return [];
      }
    } else {
      return [];
    }
  }
*/


  Future<List> getNotificationsList() async {
    final DocumentReference ref = firestore.collection('notifications').doc('contents');
    DocumentSnapshot snap = await ref.get();
    if (snap.exists == true) {
      List notificationsList = snap['list'] ?? [];
      if(notificationsList.isNotEmpty){
        List<int> a = notificationsList.map((e) => int.parse(e)).toList()..sort();
        List<String> b = a.reversed.toList().take(10).toList().map((e) => e.toString()).toList();
        return b;
      }else{
        return notificationsList;
      }
    } else {
      return [];
    }
  }


  Future<List> _getArticlesByIds(ids) {
    return firestore
        .collection('contents')
        .where('timestamp', whereIn: ids)
        .get()
        .then((QuerySnapshot snapshot) {
      return snapshot.docs.map((DocumentSnapshot doc) => Article.fromFirestore(doc)).toList();
    });
  }

  Future<Null> getData(mounted) async {
    await getNotificationsList().then((list)async {
      if(list.isNotEmpty){

      _hasData = true;
      QuerySnapshot rawData;

        rawData = await firestore
            .collection('contents')
            .where('timestamp', whereIn: list)
            //.limit(10)
            .get();

        
        if(rawData.docs.isNotEmpty){
          if (mounted) {
            _isLoading = false;
            _snap.addAll(rawData.docs);
            _data = _snap.map((e) => Article.fromFirestore(e)).toList();
            _data.sort((a,b) => b.timestamp!.compareTo(a.timestamp!));
          }
        }else{
          _hasData = false;
          _isLoading = false;
        }
        notifyListeners();
        return null;

      }else{
        notifyListeners();
        return null;
      }
    });
  }


  onRefresh(mounted) {
    _isLoading = true;
    _snap.clear();
    _data.clear();
    getData(mounted);
    notifyListeners();
  }



}
