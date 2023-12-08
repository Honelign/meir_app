import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:news_app/models/article.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchBloc with ChangeNotifier {
  SearchBloc() {
    getRecentSearchList();
  }

  List<String> _recentSearchData = [];

  List<String> get recentSearchData => _recentSearchData;

  String _searchText = '';

  String get searchText => _searchText;

  bool _searchStarted = false;

  bool get searchStarted => _searchStarted;
  String category = '';

  TextEditingController _textFieldCtrl = TextEditingController();

  TextEditingController get textfieldCtrl => _textFieldCtrl;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future getRecentSearchList() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _recentSearchData = sp.getStringList('recent_search_data') ?? [];
    notifyListeners();
  }

  Future addToSearchList(String value) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _recentSearchData.add(value);
    await sp.setStringList('recent_search_data', _recentSearchData);
    notifyListeners();
  }

  Future removeFromSearchList(String value) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _recentSearchData.remove(value);
    await sp.setStringList('recent_search_data', _recentSearchData);
    notifyListeners();
  }

  Future<List> getData() async {
    List<Article> data = [];
    QuerySnapshot rawData = (category.isEmpty)
        ? await firestore
            .collection('contents')
            .orderBy('timestamp', descending: true)
            .get()
        : await firestore
            .collection('contents')
            .orderBy('timestamp', descending: true)
            .where('category', isEqualTo: category)
            .get();

    List<DocumentSnapshot> _snap = [];
    _snap.addAll(rawData.docs.where((u) => (u['title']
            .toLowerCase()
            .contains(_searchText.toLowerCase()) ||
        /*u['category'].toLowerCase().contains(_searchText.toLowerCase()) ||*/
        u['description'].toLowerCase().contains(_searchText.toLowerCase()))));
    data = _snap.map((e) => Article.fromFirestore(e)).toList();
    return data;
  }

  onFieldSubmitted() async {
    if (_textFieldCtrl.text.isEmpty) return;
    _searchText = _textFieldCtrl.text;
    _searchStarted = true;
    //notifyListeners();
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _recentSearchData.add(_textFieldCtrl.text);
    await sp.setStringList('recent_search_data', _recentSearchData);
    notifyListeners();
  }

  setSearchText(value) {
    if (_textFieldCtrl.text != value) _textFieldCtrl.text = value;
    _searchText = value;
    _searchStarted = true;
    notifyListeners();
  }

  saerchInitialize(String? category) {
    _textFieldCtrl.clear();
    _searchStarted = false;
    this.category = category!;
    notifyListeners();
  }
}
