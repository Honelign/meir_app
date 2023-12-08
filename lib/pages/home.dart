import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:news_app/blocs/ads_bloc.dart';
import 'package:news_app/blocs/notification_bloc.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/pages/bookmarks.dart';
import 'package:news_app/pages/categories.dart';
import 'package:news_app/pages/explore.dart';
import 'package:news_app/pages/profile.dart';
import 'package:news_app/pages/videos.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app.dart';
import '../config/config.dart';
import '../main.dart';
import '../services/app_service.dart';
import '../utils/next_screen.dart';
import '../widgets/audio_player_widget.dart';

class HomePage extends StatefulWidget {
  String? articleId;

  HomePage({Key? key, this.articleId}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _currentIndex = 0;
  PageController _pageController = PageController();
  bool isPlayerShowing = true;
  bool isItemFound = true;
  List<IconData> iconList = [
    Feather.home,
    Feather.bookmark,
    Feather.grid,
    Feather.heart,
    Feather.user
  ];
  late SharedPreferences preferences;

  void onTabTapped(int index) {
    if (index == 3) {
      AppService().openLink(context, Config().donateUrl);
      return;
    }
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(index,
        curve: Curves.easeIn, duration: Duration(milliseconds: 250));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    checkForRateUsDialog();
    Future.delayed(Duration(milliseconds: 0)).then((value) async {
      final adb = context.read<AdsBloc>();
      await context
          .read<NotificationBloc>()
          .initFirebasePushNotification(context)
          .then((value) =>
              context.read<NotificationBloc>().handleNotificationlength())
          .then((value) => adb.checkAdsEnable())
          .then((value) async {
        if (adb.interstitialAdEnabled == true || adb.bannerAdEnabled == true) {
          adb.initiateAds();
        }
      });
      if (widget.articleId == null || widget.articleId!.isEmpty) {
        if (!isNotificationClick) {
/*
          FeatureDiscovery.clearPreferences(context, <String>{
            'q_and_a',
            'search_articles_id',
            'video_articles_id',
            "notification_id"
          });
*/
          SchedulerBinding.instance!.addPostFrameCallback((Duration duration) {
            FeatureDiscovery.discoverFeatures(
              context,
              const <String>{
/*
                'search_articles_id',
                'q_and_a',
                "notification_id"
*/
              },
            );
          });
        }
      }
    });
    //https://torasavigdor.org/20220317203539
    //applink://torasavigdor.org/20220317203539
    if (widget.articleId != null && widget.articleId!.isNotEmpty) {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      firestore.collection('contents').doc(widget.articleId!).get().then(
          (value) => {
                navigateToDetailsScreen(
                    context, Article.fromFirestore(value), null)
              });
    }
    initPreferances();
  }

  @override
  void dispose() {
    _pageController.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        print("Inactive");
        break;
      case AppLifecycleState.detached:
        print("Detached");
        break;
      case AppLifecycleState.resumed:
        print("Resumed");
        break;
      case AppLifecycleState.paused:
        print("Paused");
        break;
      default:
        break;
    }
  }

  Future _onWillPop() async {
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      _pageController.animateToPage(0,
          duration: Duration(milliseconds: 200), curve: Curves.easeIn);
    } else {
      await SystemChannels.platform
          .invokeMethod<void>('SystemNavigator.pop', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => await _onWillPop(),
      child: Scaffold(
        bottomNavigationBar: _bottomNavigationBar(),
        body: Stack(
          children: [
            PageView(
              controller: _pageController,
              allowImplicitScrolling: false,
              physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                Explore(
                    onDrawerChange: (isDrawerOpen) => {
                          this.setState(() {
                            isPlayerShowing = !isDrawerOpen;
                          })
                        }),
                BookmarkPage(),
                Categories(false),
                Container(
                  child: Center(
                    child: Text("Donate"),
                  ),
                ),
                ProfilePage()
              ],
            ),
            isPlayerShowing ? buildAudioPlayer() : Container(),
          ],
        ),
      ),
    );
  }

  Widget buildAudioPlayer() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: StreamBuilder<AudioProcessingState>(
        stream: audioHandler.playbackState
            .map((state) => state.processingState)
            .distinct(),
        builder: (context, snapshot) {
          final processingState = snapshot.data ?? AudioProcessingState.idle;
          /*switch(describeEnum(processingState)) {
                        case 'idle':
                          break;
                        case 'loading':
                          break;
                        case 'ready':
                          break;
                      }*/
          return (describeEnum(processingState) == 'idle')
              ? Container()
              : Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          Color(0xff7878ff),
                          Color(0xff00008B)
                          //add more colors for gradient
                        ],
                        begin: Alignment.topLeft, //begin of the gradient color
                        end: Alignment.bottomRight, //end of the gradient color
                        stops: [0, 0.9] //stops for individual color
                        //set the stops number equal to numbers of color
                        ),
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          StreamBuilder<MediaItem?>(
                            stream: audioHandler.mediaItem,
                            builder: (context, snapshot) {
                              final mediaItem = snapshot.data;
                              return Expanded(
                                child: Text(
                                  mediaItem?.title ?? "",
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.6,
                                      wordSpacing: 1),
                                ),
                              );
                            },
                          ),
                          SizedBox(width: 8.0),
                          (describeEnum(processingState) == 'loading')
                              ? Container(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator())
                              : Container(),
                          SizedBox(width: 8.0),
                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(22)),
                            child: Container(
                              width: 40,
                              height: 40,
                              color: Color(0x33000000),
                              child: IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.white70,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    audioHandler.stop();
                                  }),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          StreamBuilder<bool>(
                            stream: audioHandler.playbackState
                                .map((state) => state.playing)
                                .distinct(),
                            builder: (context, snapshot) {
                              final playing = snapshot.data ?? false;
                              return (playing)
                                  ? ClipRRect(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(22)),
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        color: Color(0x33000000),
                                        child: IconButton(
                                            icon: Icon(
                                              Icons.pause_circle_filled,
                                              color: Colors.white70,
                                              size: 34,
                                            ),
                                            onPressed: () {
                                              audioHandler.pause();
                                              //_pause();
                                            }),
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(22)),
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        color: Color(0x33000000),
                                        child: IconButton(
                                            icon: Icon(
                                              Icons.play_circle_filled,
                                              color: Colors.white70,
                                              size: 34,
                                            ),
                                            onPressed: () {
                                              if (audioHandler
                                                      .mediaItem.value !=
                                                  null) audioHandler.play();
                                            }),
                                      ),
                                    );
                            },
                          ),
                          StreamBuilder<MediaState>(
                            stream: mediaStateStream,
                            builder: (context, snapshot) {
                              final mediaState = snapshot.data;
                              preferences.setString(
                                  'CurrentPlayingPosition',
                                  jsonEncode(mediaState?.position.inSeconds)
                                      .toString());
                              return Expanded(
                                child: SeekBar(
                                  duration: mediaState?.mediaItem?.duration ??
                                      Duration.zero,
                                  position:
                                      mediaState?.position ?? Duration.zero,
                                  onChangeEnd: (newPosition) {
                                    /*await prefs.setString('CurrentPlayingPosition', jsonEncode(newPosition).toString());*/
                                    audioHandler.seek(newPosition);
                                  },
                                ),
                              );
                            },
                          ),
                          /*ClipRRect(
                                        borderRadius:
                                        BorderRadius.all(
                                            Radius.circular(
                                                22)),
                                        child: Container(
                                          width: 50,
                                          height: 50,
                                          color: Color(0x33000000),
                                          child: IconButton(
                                              icon: Icon(
                                                Icons.stop_circle,
                                                color: Colors.white70,
                                                size: 34,
                                              ),
                                              onPressed: () {
                                                audioHandler.stop();
                                                //_stop();
                                              }),
                                        ),
                                      ),
                                      SizedBox(width: 10.0),*/
                          StreamBuilder<double>(
                            stream: audioHandler.playbackState
                                .map((state) => state.speed)
                                .distinct(),
                            builder: (context, snapshot) {
                              double speed = snapshot.data ?? 1.0;
                              return ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(22)),
                                child: Container(
                                  width: 55,
                                  height: 45,
                                  color: Color(0x33000000),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (speed == 1.75)
                                        speed = 1.0;
                                      else
                                        speed = speed + 0.25;
                                      //_audioPlayer.setPlaybackRate(playbackRate);
                                      audioHandler.setSpeed(speed);
                                    },
                                    child: Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Center(
                                            child: Text(
                                          speed.toString() + 'x',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ))),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }

  BottomNavigationBar _bottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      onTap: (index) => onTabTapped(index),
      currentIndex: _currentIndex,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      iconSize: 25,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(iconList[0]), label: 'home'.tr()),
        BottomNavigationBarItem(
            icon: DescribedFeatureOverlay(
              featureId: 'video_articles_id',
              tapTarget: Icon(iconList[1]),
              title: Text('Videos'),
              description: Text('Video posts here.'),
              backgroundColor: Theme.of(context).primaryColor,
              targetColor: Colors.white,
              textColor: Colors.white,
              child: Icon(iconList[1]),
            ),
            label: 'Bookmarks'.tr()),
/*
        BottomNavigationBarItem(
            icon: Icon(iconList[1]),
            label: 'videos'.tr()),
*/
        BottomNavigationBarItem(
            icon: Icon(
              iconList[2],
              size: 25,
            ),
            label: 'categories'.tr()),
        BottomNavigationBarItem(icon: Icon(iconList[3]), label: 'Donate'),
        BottomNavigationBarItem(icon: Icon(iconList[4]), label: 'profile'.tr())
      ],
    );
  }

  Future<void> checkForRateUsDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int nbTimesLaunched = prefs.getInt('nbTimesLaunched') ?? 0;
    print("Opened : " + nbTimesLaunched.toString());
    if (nbTimesLaunched >= 10) {
      print("Showing rate us");
      await Future.delayed(Duration(seconds: 10));
      print('showing dialog');
      _showMyDialog();
      await prefs.setInt('nbTimesLaunched', 0);
    }
  }

  void _showMyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(22.0))),
          title: new Text("Rate this app"),
          content: new Text(
              "Hi, take a minute to rate this app and help support to improve new features ;)"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new TextButton(
              child: new Text("Rate Now"),
              onPressed: () async {
                Navigator.of(context).pop();
                AppService().launchAppReview(context);
              },
            ),
            new TextButton(
              child: new Text("May be later"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> initPreferances() async {
    preferences = await SharedPreferences.getInstance();

    String? id = await preferences.getString('CurrentPlayingItemId');
    String? title = await preferences.getString('CurrentPlayingItemTitle');
    String? durationSeconds =
        await preferences.getString('CurrentPlayingItemDuration');

    MediaItem item = MediaItem(
      id: id!,
      album: 'Album name',
      title: title!,
      artist: 'Artist name',
      duration: Duration(seconds: int.parse(durationSeconds!)),
    );

    audioHandler.playMediaItem(item);

    /*prefs = await SharedPreferences.getInstance();
    String? item = await prefs.getString("CurrentPlayingItem");
    if (item != null) {
      setState(() {
        isItemFound = true;
      });
      audioHandler.playbackState.listen((value) {
        if (describeEnum(value.processingState) == 'idle'){
          MediaItem mediaItem = jsonDecode(item);
          audioHandler.playMediaItem(mediaItem);
        }
      });
    }*/
  }
}

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  SeekBar({
    required this.duration,
    required this.position,
    this.bufferedPosition = Duration.zero,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragValue;
  bool _dragging = false;
  late SliderThemeData _sliderThemeData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _sliderThemeData = SliderTheme.of(context).copyWith(
      trackHeight: 2.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final value = min(
      _dragValue ?? widget.position.inMilliseconds.toDouble(),
      widget.duration.inMilliseconds.toDouble(),
    );
    if (_dragValue != null && !_dragging) {
      _dragValue = null;
    }
    return Stack(
      children: [
        SliderTheme(
          data: _sliderThemeData.copyWith(
            thumbShape: HiddenThumbComponentShape(),
            activeTrackColor: Colors.orangeAccent,
            inactiveTrackColor: Colors.grey.shade300,
          ),
          child: ExcludeSemantics(
            child: Slider(
              min: 0.0,
              max: widget.duration.inMilliseconds.toDouble(),
              value: min(widget.bufferedPosition.inMilliseconds.toDouble(),
                  widget.duration.inMilliseconds.toDouble()),
              onChanged: (value) {},
            ),
          ),
        ),
        SliderTheme(
          data: _sliderThemeData.copyWith(
            inactiveTrackColor: Colors.transparent,
          ),
          child: Slider(
            min: 0.0,
            max: widget.duration.inMilliseconds.toDouble(),
            value: value,
            onChanged: (value) {
              if (!_dragging) {
                _dragging = true;
              }
              setState(() {
                _dragValue = value;
              });
              if (widget.onChanged != null) {
                widget.onChanged!(Duration(milliseconds: value.round()));
              }
            },
            onChangeEnd: (value) {
              if (widget.onChangeEnd != null) {
                widget.onChangeEnd!(Duration(milliseconds: value.round()));
              }
              _dragging = false;
            },
          ),
        ),
        Positioned(
          right: 16.0,
          bottom: 0.0,
          child: Text(
              RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                      .firstMatch("$_remaining")
                      ?.group(1) ??
                  '$_remaining',
              style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Duration get _remaining => widget.duration - widget.position;
}
