import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
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

class StaticPage extends StatefulWidget {
  final String title;
  final String dataString;

  const StaticPage(this.title, this.dataString, {Key? key}) : super(key: key);

  @override
  _StaticPageState createState() => _StaticPageState();
}

class _StaticPageState extends State<StaticPage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title).tr(),
            centerTitle: false,
          ),
          body: SingleChildScrollView(child: Container(
              padding: EdgeInsets.all(12),
              child: Html(data: widget.dataString))),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
