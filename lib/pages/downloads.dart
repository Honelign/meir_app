import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:news_app/blocs/bookmark_bloc.dart';
import 'package:news_app/blocs/sign_in_bloc.dart';
import 'package:news_app/cards/card4.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/models/book.dart';
import 'package:news_app/utils/empty.dart';
import 'package:news_app/utils/loading_cards.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../config/config.dart';
import '../services/app_service.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({Key? key}) : super(key: key);

  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage>
    with AutomaticKeepAliveClientMixin {

  List<Book> books = [
    Book(title: "Set of Six (6) Books - Merkavot Argaman Shutim (Blue)", image: "assets/images/book1.jpg", price: "\$225.00", url: "https://rabimeir.org/buy-now?store-page=Set-of-Six-6-Books-Merkavot-Argaman-Shutim-Blue-p130117125"),
    Book(title: "Set of One (1) Book - Merkavot Argaman Shutim (Blue)", image: "assets/images/book2.jpg", price: "\$40.00", url: "https://rabimeir.org/buy-now?store-page=Set-of-One-1-Book-Merkavot-Argaman-Shutim-Blue-p130117146"),
    Book(title: "Set of Three (3) Books - Merkavot Argaman Shutim (Green)", image: "assets/images/book3.jpg", price: "\$60.00", url: "https://rabimeir.org/buy-now?store-page=Set-of-Three-3-Books-Merkavot-Argaman-Shutim-Green-p130117164"),
    Book(title: "Set of One (1) Book - Guide for Holy Souls (Brown) *NEW*", image: "assets/images/book4.jpg", price: "\$38.00", url: "https://rabimeir.org/buy-now?store-page=Set-of-One-1-Book-Guide-for-Holy-Souls-Brown-*NEW*-p140008441"),
    Book(title: "One (1) USB - 450 HOURS OF LECTURES", image: "assets/images/book5.jpg", price: "\$50.00", url: "https://rabimeir.org/buy-now?store-page=One-1-USB-450-HOURS-OF-LECTURES-p130117201"),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Sefarim').tr(),
            centerTitle: false,
          ),
          body: GridView.count(
            padding: EdgeInsets.all(6),
            childAspectRatio: 0.8,
            crossAxisCount: 2,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  AppService().openLink(context, books[index].url!);
                },
                child: Container(
                  margin: EdgeInsets.all(6),
                  width: double.maxFinite,
                  height: double.maxFinite,
                  child: Column(children: [
                    Expanded(
                      child: Image(
                        width: double.maxFinite,
                        image: AssetImage(books[index].image!),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                    Text(books[index].title!),
                    Text(books[index].price!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),),
                  ],),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
