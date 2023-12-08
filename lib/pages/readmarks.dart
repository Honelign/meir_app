import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:news_app/blocs/bookmark_bloc.dart';
import 'package:news_app/blocs/mark_read_bloc.dart';
import 'package:news_app/blocs/sign_in_bloc.dart';
import 'package:news_app/cards/card4.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/utils/empty.dart';
import 'package:news_app/utils/loading_cards.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class ReadMarkPage extends StatefulWidget {
  const ReadMarkPage({Key? key}) : super(key: key);

  @override
  _ReadMarkPageState createState() => _ReadMarkPageState();
}

class _ReadMarkPageState extends State<ReadMarkPage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final SignInBloc sb = context.watch<SignInBloc>();

    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text('readmarks').tr(),
          centerTitle: false,
        ),
        body: sb.guestUser
            ? EmptyPage(
                icon: Feather.user_plus,
                message: 'sign in first'.tr(),
                message1: "sign in to save your read marked articles here".tr(),
              )
            : ReadMarkedArticles(),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ReadMarkedArticles extends StatefulWidget {
  const ReadMarkedArticles({Key? key}) : super(key: key);

  @override
  _ReadMarkedArticlesState createState() => _ReadMarkedArticlesState();
}

class _ReadMarkedArticlesState extends State<ReadMarkedArticles> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: context.watch<MarkReadBloc>().getArticles(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState.name == "done") {
            if (!snapshot.hasData || snapshot.data == [] || snapshot.data.length == 0)
              return EmptyPage(
                icon: Icons.check_circle_outline,
                message: 'no articles found'.tr(),
                message1: 'save your read marked articles here'.tr(),
              );
            else return ListView.separated(
              padding: EdgeInsets.all(15),
              itemCount: snapshot.data.length,
              separatorBuilder: (context, index) => SizedBox(
                height: 15,
              ),
              itemBuilder: (BuildContext context, int index) {
                return Card4(d: snapshot.data[index], heroTag: 'bookmarks$index',);
              },
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(15),
            itemCount: 8,
            separatorBuilder: (BuildContext context, int index) => SizedBox(
              height: 15,
            ),
            itemBuilder: (BuildContext context, int index) {
              return LoadingCard(height: 160);
            },
          );
        },
      ),
    );
  }
}
