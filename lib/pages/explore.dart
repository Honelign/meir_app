import 'package:badges/badges.dart' as badge;
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:line_icons/line_icons.dart';
import 'package:md2_tab_indicator/md2_tab_indicator.dart';
import 'package:news_app/blocs/featured_bloc.dart';
import 'package:news_app/blocs/notification_bloc.dart';
import 'package:news_app/blocs/recent_articles_bloc.dart';
import 'package:news_app/blocs/popular_articles_bloc.dart';
import 'package:news_app/blocs/tab_index_bloc.dart';
import 'package:news_app/config/config.dart';
import 'package:news_app/pages/notifications.dart';
import 'package:news_app/pages/search.dart';
import 'package:news_app/utils/app_name.dart';
import 'package:news_app/utils/next_screen.dart';
import 'package:news_app/widgets/drawer.dart';
import 'package:news_app/widgets/tab_medium.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class Explore extends StatefulWidget {
  Function? onDrawerChange;
  Explore({Key? key, this.onDrawerChange}) : super(key: key);

  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  TabController? _tabController;

  List<Widget> _tabs = [
    Tab(
      text: " חדש ",
    ),
    Tab(
      text: Config().initialCategories[0],
    ),
    Tab(
      text: Config().initialCategories[1],
    ),
    Tab(
      text: Config().initialCategories[2],
    ),
    Tab(
      text: Config().initialCategories[3],
    ),
    Tab(
      text: Config().initialCategories[4],
    ),
    Tab(
      text: "More".tr(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController!.addListener(() {
      context.read<TabIndexBloc>().setTabIndex(_tabController!.index);
    });
    Future.delayed(Duration(milliseconds: 0)).then((value) {
      context.read<FeaturedBloc>().getData();
      context.read<RecentBloc>().getData();
      context.read<PopularBloc>().getData(mounted);
    });
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      onDrawerChanged: (isOpened) {
        widget.onDrawerChange!(isOpened);
      },
      drawer: DrawerMenu(),
      key: scaffoldKey,
      body: Stack(
        children: [
          Positioned(
            top: 70,
            left: 80,
            child: DescribedFeatureOverlay(
              featureId: 'q_and_a',
              tapTarget: const Text("Q & A"),
              title: Text('Text Articles'),
              description: Text('You can now COPY any text on the app and share it across your platforms as you wish!'),
              backgroundColor: Config().appColor,
              targetColor: Colors.white,
              textColor: Colors.white,
              child: Container(),
            ),
          ),
          NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                automaticallyImplyLeading: false,
                centerTitle: false,
                titleSpacing: 0,
                title: AppName(fontSize: 19.0),
                leading: IconButton(
                  icon: Icon(
                    Feather.menu,
                    size: 25,
                  ),
                  onPressed: () {
                    scaffoldKey.currentState!.openDrawer();
                  },
                ),
                elevation: 1,
                actions: <Widget>[
                  DescribedFeatureOverlay(
                    featureId: 'search_articles_id',
                    tapTarget: const Icon(
                      AntDesign.search1,
                      size: 22,
                    ),
                    title: Text('Search'),
                    description: Text('Now you can search quicker and by category!'),
                    backgroundColor: Config().appColor,
                    targetColor: Colors.white,
                    textColor: Colors.white,
                    child: IconButton(
                      icon: Icon(
                        AntDesign.search1,
                        size: 22,
                      ),
                      onPressed: () {
                        nextScreen(
                            context,
                            SearchPage(
                              category: '',
                            ));
                      },
                    ),
                  ),
                  DescribedFeatureOverlay(
                    featureId: 'notification_id',
                    tapTarget: const Icon(
                      LineIcons.bell,
                      size: 25,
                    ),
                    title: Text('Notifications'),
                    description: Text('All new notifications will now take you DIRECTLY to the article posted.  In addition a record of the notification will appear right here on your notifications tab!'),
                    backgroundColor: Config().appColor,
                    targetColor: Colors.white,
                    textColor: Colors.white,
                    child: badge.Badge(
                      position: badge.BadgePosition.topEnd(top: 14, end: 15),
                      badgeStyle: badge.BadgeStyle(
                        badgeColor: Colors.redAccent,
                      ),
                      badgeAnimation: badge.BadgeAnimation.fade(),
                      showBadge: context.watch<NotificationBloc>().savedNlength <
                          context.watch<NotificationBloc>().notificationLength
                          ? true
                          : false,
                      badgeContent: Container(),
                      child: IconButton(
                        icon: Icon(
                          LineIcons.bell,
                          size: 25,
                        ),
                        onPressed: () {
                          context.read<NotificationBloc>().saveNlengthToSP();
                          nextScreen(context, NotificationsPage());
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  )
                ],
                pinned: true,
                floating: true,
                forceElevated: innerBoxIsScrolled,
                bottom: TabBar(
                  labelStyle: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Color(0xff5f6368),
                  //niceish grey
                  isScrollable: true,
                  indicator: MD2Indicator(
                    //it begins here
                    indicatorHeight: 3,
                    indicatorColor: Theme.of(context).primaryColor,
                    indicatorSize: MD2IndicatorSize.normal,
                  ),
                  tabs: _tabs,
                ),
              ),
            ];
          }, body: Builder(
            builder: (BuildContext context) {
              final innerScrollController = PrimaryScrollController.of(context);
              return TabMedium(
                sc: innerScrollController,
                tc: _tabController,
              );
            },
          )),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
