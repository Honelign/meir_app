import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:news_app/models/article.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarkReadBloc extends ChangeNotifier {

  Future<List> getArticles() async {

    String _collectionName = 'contents';
    String _fieldName = 'read marked items';

    SharedPreferences sp = await SharedPreferences.getInstance();
    String? _uid = sp.getString('uid');
    

    final DocumentReference ref = FirebaseFirestore.instance.collection('users').doc(_uid);
    DocumentSnapshot snap = await ref.get();
    List readMarkedList = snap[_fieldName];
    print('mainList: $readMarkedList');

    List d = [];
    if (readMarkedList.isEmpty) return d;
    if(readMarkedList.length <= 10){
      await FirebaseFirestore.instance
        .collection(_collectionName)
        .where('timestamp', whereIn: readMarkedList)
        .get()
        .then((QuerySnapshot snap) {
          d.addAll(snap.docs.map((e) => Article.fromFirestore(e)).toList());
      });

    }else if(readMarkedList.length > 10){
      int size = 10;
      var chunks = [];

      for(var i = 0; i< readMarkedList.length; i+= size){
        var end = (i+size<readMarkedList.length)?i+size:readMarkedList.length;
        chunks.add(readMarkedList.sublist(i,end));
      }

      await FirebaseFirestore.instance
        .collection(_collectionName)
        .where('timestamp', whereIn: chunks[0])
        .get()
        .then((QuerySnapshot snap) {
          d.addAll(snap.docs.map((e) => Article.fromFirestore(e)).toList());
      }).then((value)async{
        await FirebaseFirestore.instance
        .collection(_collectionName)
        .where('timestamp', whereIn: chunks[1])
        .get()
        .then((QuerySnapshot snap) {
          d.addAll(snap.docs.map((e) => Article.fromFirestore(e)).toList());
        });
      });

    }else if(readMarkedList.length > 20){
      int size = 10;
      var chunks = [];

      for(var i = 0; i< readMarkedList.length; i+= size){
        var end = (i+size<readMarkedList.length)?i+size:readMarkedList.length;
        chunks.add(readMarkedList.sublist(i,end));
      }

      await FirebaseFirestore.instance
        .collection(_collectionName)
        .where('timestamp', whereIn: chunks[0])
        .get()
        .then((QuerySnapshot snap) {
          d.addAll(snap.docs.map((e) => Article.fromFirestore(e)).toList());
      }).then((value)async{
        await FirebaseFirestore.instance
        .collection(_collectionName)
        .where('timestamp', whereIn: chunks[1])
        .get()
        .then((QuerySnapshot snap) {
          d.addAll(snap.docs.map((e) => Article.fromFirestore(e)).toList());
        });
      }).then((value)async{
        await FirebaseFirestore.instance
        .collection(_collectionName)
        .where('timestamp', whereIn: chunks[2])
        .get()
        .then((QuerySnapshot snap) {
          d.addAll(snap.docs.map((e) => Article.fromFirestore(e)).toList());
        });
      });
    }

    
    return d.reversed.toList();
  
  }

  Future onReadMarkIconClick(String? timestamp) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String? _uid = sp.getString('uid');
    String _fieldName = 'read marked items';
    
    final DocumentReference ref = FirebaseFirestore.instance.collection('users').doc(_uid);
    DocumentSnapshot snap = await ref.get();
    List d = [];
    try {
      d = snap[_fieldName];
    } catch(e) {
      await ref.update({_fieldName: []});
    }
    

    if (d.contains(timestamp)) {

      List a = [timestamp];
      await ref.update({_fieldName: FieldValue.arrayRemove(a)});
      

    } else {

      d.add(timestamp);
      await ref.update({_fieldName: FieldValue.arrayUnion(d)});
      
      
    }

    notifyListeners();
  }

}