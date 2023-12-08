import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:html/parser.dart';
import 'package:news_app/blocs/ads_bloc.dart';
import 'package:news_app/blocs/bookmark_bloc.dart';
import 'package:news_app/blocs/mark_read_bloc.dart';
import 'package:news_app/blocs/sign_in_bloc.dart';
import 'package:news_app/blocs/theme_bloc.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/models/custom_color.dart';
import 'package:news_app/pages/comments.dart';
import 'package:news_app/services/app_service.dart';
import 'package:news_app/utils/cached_image.dart';
import 'package:news_app/utils/sign_in_dialog.dart';
import 'package:news_app/widgets/banner_ad_admob.dart'; //admob
//import 'package:news_app/widgets/banner_ad_fb.dart';      //fb ad
import 'package:news_app/widgets/bookmark_icon.dart';
import 'package:news_app/widgets/html_body.dart';
import 'package:news_app/widgets/love_count.dart';
import 'package:news_app/widgets/love_icon.dart';
import 'package:news_app/widgets/readmark_icon.dart';
import 'package:news_app/widgets/related_articles.dart';
import 'package:news_app/widgets/views_count.dart';
import 'package:share/share.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/config.dart';
import '../main.dart';
import '../services/dynamic_link.dart';
import '../utils/next_screen.dart';
import 'home.dart';

class ArticleDetails extends StatefulWidget {
  final Article? data;
  final String? tag;

  const ArticleDetails({Key? key, required this.data, required this.tag})
      : super(key: key);

  @override
  _ArticleDetailsState createState() => _ArticleDetailsState();
}

class _ArticleDetailsState extends State<ArticleDetails> {
  double rightPaddingValue = 130;
  ScrollController? scrollController;

  late SharedPreferences preferences;



  void _handleShare() {
    DynamicLinkProvider().createLink(widget.data!.timestamp!).then((value) => Share.share('${widget.data!.title}, Check this out on the latest Rav Meir Eliyahu app, I know you will find this video interesting and exciting.\n${value} '));
  }

/*
  void _handleShare() {
    final sb = context.read<SignInBloc>();
    final String _shareTextAndroid =
        '${widget.data!.title}, Check this out on the latest Rav Avigdor Miller app, I know you will find this read interesting and exciting. IOS App link: torasapp://article?id=${widget.data!.timestamp!} , Android App link: https://torasavigdor.org/${widget.data!.timestamp!}';
    final String _shareTextiOS =
        '${widget.data!.title}, Check this out on the latest Rav Avigdor Miller app, I know you will find this read interesting and exciting. IOS App link: torasapp://article?id=${widget.data!.timestamp!} , Android App link: https://torasavigdor.org/${widget.data!.timestamp!}';

    if (Platform.isAndroid) {
      Share.share(_shareTextAndroid);
    } else {
      Share.share(_shareTextiOS);
    }
  }
*/

  handleLoveClick() {
    bool _guestUser = context.read<SignInBloc>().guestUser;

    if (_guestUser == true) {
      openSignInDialog(context);
    } else {
      context.read<BookmarkBloc>().onLoveIconClick(widget.data!.timestamp);
    }
  }

  handleCopyArticle() async {
    String htmlString = '<h2 style="font-size:10vw">'+widget.data!.title! +'</h2><br/>'+widget.data!.description!;
    final document = parse(htmlString);
    final String parsedString = parse(document.body!.text).documentElement!.text;

    await Clipboard.setData(ClipboardData(text: parsedString));

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Article Copied")));
  }

  handleBookmarkClick() {
    bool _guestUser = context.read<SignInBloc>().guestUser;

    if (_guestUser == true) {
      openSignInDialog(context);
    } else {
      context.read<BookmarkBloc>().onBookmarkIconClick(widget.data!.timestamp);
    }
  }

  handleReadMarkClick() {
    bool _guestUser = context.read<SignInBloc>().guestUser;

    if (_guestUser == true) {
      openSignInDialog(context);
    } else {
      context.read<MarkReadBloc>().onReadMarkIconClick(widget.data!.timestamp);
    }
  }

  handlePrintClick() async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => await Printing.convertHtml(
        format: format,
        html: '<?xml version="1.0"?><html><body style="margin:40px;padding:0">'+"<h1>" + widget.data!.title! + "</h1>" + widget.data!.description!+"</body></html>",
      ),
      name: widget.data!.title!,
      usePrinterSettings: true
    );
  }

  @override
  void initState() {
    super.initState();
    scrollController = new ScrollController();
    Future.delayed(Duration(milliseconds: 100)).then((value) {
      setState(() {
        rightPaddingValue = 10;
      });
    });

    Future.delayed(Duration(milliseconds: 0)).then((value) async {
      initPrefs();
    });

/*
    FeatureDiscovery.clearPreferences(context, <String>{
      'print_id',
      'share_id',
      'read_id',
      'copy_id',
    });
*/
    SchedulerBinding.instance!.addPostFrameCallback((Duration duration) {
      FeatureDiscovery.discoverFeatures(
        context,
        const <String>{
          /*'print_id',
          'share_id',
          'read_id',
          'copy_id',*/
        },
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sb = context.watch<SignInBloc>();
    final Article article = widget.data!;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          bottom: true,
          top: false,
          maintainBottomViewPadding: true,
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      controller: scrollController,
                      slivers: <Widget>[
                        _customAppBar(article, context),
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 15, 20, 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: <Widget>[
                                            Container(
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: context
                                                              .watch<ThemeBloc>()
                                                              .darkTheme ==
                                                          false
                                                      ? CustomColor()
                                                          .loadingColorLight
                                                      : CustomColor()
                                                          .loadingColorDark,
                                                ),
                                                child: AnimatedPadding(
                                                  duration:
                                                      Duration(milliseconds: 1000),
                                                  padding: EdgeInsets.only(
                                                      left: 10,
                                                      right: rightPaddingValue,
                                                      top: 5,
                                                      bottom: 5),
                                                  child: Text(
                                                    article.category!,
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                )),
                                            Spacer(),
                                            DescribedFeatureOverlay(
                                              featureId: 'print_id',
                                              tapTarget: const Icon(Icons.print_outlined),
                                              title: Text('Print Articles'),
                                              description: Text('You can now PRINT any QA\nor PARSHA directly from\nyour phone to your printer!'),
                                              backgroundColor: Config().appColor,
                                              targetColor: Colors.white,
                                              textColor: Colors.white,
                                              child: IconButton(
                                                  icon: Icon(Icons.print_outlined),
                                                  onPressed: () {
                                                    handlePrintClick();
                                                  }),
                                            ),
                                            DescribedFeatureOverlay(
                                              featureId: 'read_id',
                                              tapTarget: BuildReadMarkIcon(
                                                  collectionName: 'contents',
                                                  uid: sb.uid,
                                                  timestamp: article.timestamp),
                                              title: Text('Mark as read'),
                                              description: Text('When you click on this, your article\nwill be marked as “read” and will\nno longer appear here'),
                                              backgroundColor: Config().appColor,
                                              targetColor: Colors.white,
                                              textColor: Colors.white,
                                              child: IconButton(
                                                  icon: BuildReadMarkIcon(
                                                      collectionName: 'contents',
                                                      uid: sb.uid,
                                                      timestamp: article.timestamp),
                                                  onPressed: () {
                                                    handleReadMarkClick();
                                                  }),
                                            ),
                                            IconButton(
                                                icon: BuildLoveIcon(
                                                    collectionName: 'contents',
                                                    uid: sb.uid,
                                                    timestamp: article.timestamp),
                                                onPressed: () {
                                                  handleLoveClick();
                                                }),
                                            IconButton(
                                                icon: BuildBookmarkIcon(
                                                    collectionName: 'contents',
                                                    uid: sb.uid,
                                                    timestamp: article.timestamp),
                                                onPressed: () {
                                                  handleBookmarkClick();
                                                }),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Icon(CupertinoIcons.time_solid,
                                                size: 18, color: Colors.grey),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              article.date!,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .secondaryHeaderColor,
                                                  fontSize: 12),
                                            ),
                                            Spacer(),
                                            DescribedFeatureOverlay(
                                              featureId: 'copy_id',
                                              tapTarget: Icon(Icons.copy, size: 22),
                                              title: Text('Copy'),
                                              description: Text('Want to copy the entire article ? Click this button, entire article will be copied. You can now paste it anywhere you wish across your device and apps. '),
                                              backgroundColor: Config().appColor,
                                              targetColor: Colors.white,
                                              textColor: Colors.white,
                                              child: IconButton(
                                                  icon: Icon(Icons.copy, size: 22),
                                                  onPressed: () {
                                                    handleCopyArticle();
                                                  }),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
/*
                                        Text(
                                          article.title!,
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: -0.6,
                                              wordSpacing: 1),
                                        ),
                                        Divider(
                                          color: Theme.of(context).primaryColor,
                                          endIndent: 200,
                                          thickness: 2,
                                          height: 20,
                                        ),
*/
/*
                                        TextButton.icon(
                                          style: ButtonStyle(
                                            padding:
                                                MaterialStateProperty.resolveWith(
                                                    (states) => EdgeInsets.only(
                                                        left: 10, right: 10)),
                                            backgroundColor:
                                                MaterialStateProperty.resolveWith(
                                                    (states) => Theme.of(context)
                                                        .primaryColor),
                                            shape:
                                                MaterialStateProperty.resolveWith(
                                                    (states) =>
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(3))),
                                          ),
                                          icon: Icon(Feather.message_circle,
                                              color: Colors.white, size: 20),
                                          label: Text('comments',
                                                  style: TextStyle(
                                                      color: Colors.white))
                                              .tr(),
                                          onPressed: () {
                                            nextScreen(
                                                context,
                                                CommentsPage(
                                                    timestamp: article.timestamp));
                                          },
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
*/
/*
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            //views feature
                                            ViewsCount(
                                              article: article,
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),

                                            LoveCount(
                                                collectionName: 'contents',
                                                timestamp: article.timestamp),
                                          ],
                                        ),
*/
                                      ],
                                    ),
                                  ),
                                  HtmlBodyWidget(
                                    content: '<h2 style="font-size:10vw">'+article.title! +'</h2><br/>'+article.description!,
                                    isIframeVideoEnabled: true,
                                    isVideoEnabled: true,
                                    isimageEnabled: true,
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                              Container(
                                  padding: EdgeInsets.all(20),
                                  child: RelatedArticles(
                                    category: article.category,
                                    timestamp: article.timestamp,
                                    replace: true,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // -- Banner ads --

                  context.watch<AdsBloc>().bannerAdEnabled == false
                      ? Container()
                      : BannerAdAdmob() //admob
                  //: BannerAdFb()    //fb
                ],
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    /*Padding(
                      padding: EdgeInsets.all(12),
                      child: FloatingActionButton(
                        backgroundColor: Config().appColor,
                        child: Icon(Feather.arrow_up, color: Colors.white, size: 20),
                        onPressed: () => toTop(),
                      ),
                    ),*/
                    buildAudioPlayer(),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  void toTop() {
    scrollController!.animateTo(0,
        duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
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
                        return Text(
                          mediaItem!.title,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.6,
                              wordSpacing: 1),
                        );
                      },
                    ),
                    Expanded(child: Container()),
                    (describeEnum(processingState) == 'loading')
                        ? Container(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator())
                        : Container(),
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

  SliverAppBar _customAppBar(Article article, BuildContext context) {
    return SliverAppBar(
      expandedHeight: 270,
      flexibleSpace: FlexibleSpaceBar(
          background: widget.tag == null
              ? CustomCacheImage(
                  imageUrl: article.thumbnailImagelUrl, radius: 0.0)
              : Hero(
                  tag: widget.tag!,
                  child: CustomCacheImage(
                      imageUrl: article.thumbnailImagelUrl, radius: 0.0),
                )),
      leading: IconButton(
        icon: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(22)),
          child: Container(
              padding: EdgeInsets.all(4),
              color: Color(0x44000000),
              child: const Icon(Icons.keyboard_backspace,
                  size: 22, color: Colors.white)),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: <Widget>[
        article.sourceUrl == null
            ? Container()
            : IconButton(
                icon: const Icon(Feather.external_link,
                    size: 22, color: Colors.white),
                onPressed: () => AppService()
                    .openLinkWithCustomTab(context, article.sourceUrl!),
              ),
        DescribedFeatureOverlay(
          featureId: 'share_id',
          tapTarget: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(22)),
            child: Container(
                padding: EdgeInsets.all(4),
                color: Color(0x44000000),
                child: const Icon(Icons.share, size: 22, color: Colors.white)),
          ),
          title: Text('Share Article'),
          description: Text('Now when you share an article with family or friends, they will be linked DIRECTLY to the article you shared!  If they do not have the app, it will direct them to download it!'),
          backgroundColor: Config().appColor,
          targetColor: Colors.white,
          textColor: Colors.white,
          child: IconButton(
            icon: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(22)),
              child: Container(
                  padding: EdgeInsets.all(4),
                  color: Color(0x44000000),
                  child: const Icon(Icons.share, size: 22, color: Colors.white)),
            ),
            onPressed: () {
              _handleShare();
            },
          ),
        ),
        SizedBox(
          width: 5,
        )
      ],
    );
  }

  Future<void> initPrefs() async {
    preferences = await SharedPreferences.getInstance();
  }
}
