import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:news_app/blocs/theme_bloc.dart';
import 'package:news_app/cards/sliver_card.dart';
import 'package:news_app/cards/sliver_card1.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/models/custom_color.dart';
import 'package:news_app/utils/cached_image_with_dark.dart';
import 'package:news_app/utils/empty.dart';
import 'package:news_app/utils/loading_cards.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryBasedArticles extends StatefulWidget {
  final String? category;
  final String? categoryImage;
  final String tag;
  final int? index;
  CategoryBasedArticles({Key? key, required this.category, required this.categoryImage, required this.tag, this.index}) : super(key: key);

  @override
  _CategoryBasedArticlesState createState() => _CategoryBasedArticlesState();
}

class _CategoryBasedArticlesState extends State<CategoryBasedArticles> {


  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String collectionName = 'contents';
  ScrollController? controller;
  DocumentSnapshot? _lastVisible;
  late bool _isLoading;
  List<DocumentSnapshot> _snap = [];
  List<Article> _data = [];
  bool? _hasData;

  @override
  void initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    super.initState();
    _isLoading = true;
    _getData();
  }




  onRefresh() {
    setState(() {
      _snap.clear();
      _data.clear();
      _isLoading = true;
      _lastVisible = null;
    });
    _getData();
  }




  Future<Null> _getData() async {
    setState(() => _hasData = true);
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
            .collection(collectionName)
            .where('category', isEqualTo: widget.category)
            .where('timestamp', whereNotIn: d)
            .orderBy('timestamp', descending: true)
            .limit(8)
            .get();
      else
        rawData = await firestore
            .collection(collectionName)
            .where('category', isEqualTo: widget.category)
            .where('timestamp', whereNotIn: d)
            .orderBy('timestamp', descending: true)
            .startAfter([_lastVisible!['timestamp']])
            .limit(8)
            .get();

    } else {
      if (_lastVisible == null)
        rawData = await firestore
            .collection(collectionName)
            .where('category', isEqualTo: widget.category)
            .orderBy('timestamp', descending: true)
            .limit(8)
            .get();
      else
        rawData = await firestore
            .collection(collectionName)
            .where('category', isEqualTo: widget.category)
            .orderBy('timestamp', descending: true)
            .startAfter([_lastVisible!['timestamp']])
            .limit(8)
            .get();
    }

    if (rawData.docs.length > 0) {
      _lastVisible = rawData.docs[rawData.docs.length - 1];
      if (mounted) {
        setState(() {
          _isLoading = false;
          _snap.addAll(rawData.docs);
          _data = _snap.map((e) => Article.fromFirestore(e)).toList();
        });
      }
    } else {
      if(_lastVisible == null){

        setState(() {
          _isLoading = false;
          _hasData = false;
          print('no items');
        });

        

      }else{

        setState(() {
          _isLoading = false;
          _hasData = true;
          print('no more items');
        });
        
      }
    }
    return null;
  }



  @override
  void dispose() {
    controller!.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (!_isLoading) {
      if (controller!.position.pixels == controller!.position.maxScrollExtent) {
        setState(() => _isLoading = true);
        _getData();
      }
    }
  }

  

  @override
  Widget build(BuildContext context) {
    final tb = context.watch<ThemeBloc>();
    return Scaffold(
      body: RefreshIndicator(
        child: CustomScrollView(
          controller: controller,
          slivers: <Widget>[
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: true,
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.keyboard_arrow_left,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
              backgroundColor: tb.darkTheme == false ? CustomColor().sliverHeaderColorLight : CustomColor().sliverHeaderColorDark,
              expandedHeight: MediaQuery.of(context).size.height * 0.20,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                background: Hero(
                  tag: widget.tag, 
                  child: CustomCacheImageWithDarkFilterBottom(imageUrl: widget.categoryImage, radius: 0.0, index: widget.index,),
                ),
                title: Text(
                  widget.category!,
                  style: TextStyle(color: Colors.white),
                ),
                titlePadding: EdgeInsets.only(left: 20, bottom: 15, right: 20),
              ),
            ),


            _hasData == false ?

            SliverFillRemaining(
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.30,),
                  EmptyPage(icon: Feather.clipboard, message: 'no articles found'.tr(), message1: ''),
                ],
              )
            )

            : SliverPadding(
              padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                sliver : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index < _data.length) {
                      //if(index %2 == 0 &&index != 0) return SliverCard1(d: _data[index], heroTag: 'categorybased$index',);
                      return SliverCard(d: _data[index], heroTag: 'categorybased$index',);
                    }
                    return Opacity(
                  opacity: _isLoading ? 1.0 : 0.0,
                  child: _lastVisible == null
                  ? Column(
                    children: [
                      LoadingCard(height: 200,),
                      SizedBox(height: 15,)
                    ],
                  )
                  : Center(
                    child: SizedBox(
                        width: 32.0,
                        height: 32.0,
                        child: new CupertinoActivityIndicator()),
                  ),
                
              );
                  },
                  childCount: _data.length  == 0 ? 5  : _data.length+ 1,
                ),
              ),
            )
          ],
        ),
        onRefresh: () async => onRefresh(),
      ),
    );
  }
}