import 'dart:async';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:news_app/config/config.dart';
import 'package:news_app/pages/done.dart';
import 'package:news_app/pages/welcome.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';
import '../blocs/sign_in_bloc.dart';
import '../utils/next_screen.dart';
import 'home.dart';

bool _initialURILinkHandled = false;

class SplashPage extends StatefulWidget {
  SplashPage({Key? key}) : super(key: key);

  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Uri? _initialURI;
  Uri? _currentURI;
  Object? _err;

  StreamSubscription? _streamSubscription;

  afterSplash({String? articleId}) {
    final SignInBloc sb = context.read<SignInBloc>();
    Future.delayed(Duration(milliseconds: 1500)).then((value) {
      sb.isSignedIn == true || sb.guestUser == true
          ? gotoHomePage(articleId: articleId)
          : gotoSignInPage();
    });
  }

  gotoHomePage({String? articleId}) {
    final SignInBloc sb = context.read<SignInBloc>();
    if (sb.isSignedIn == true) {
      sb.getDataFromSp();
    }
    nextScreenReplace(context, HomePage(articleId: articleId,));
  }

  gotoSignInPage() {
    nextScreenReplace(context, WelcomePage());
  }

  @override
  void initState() {
    super.initState();

    _initURIHandler();
    _incomingLinkHandler();
  }

  Future<void> _initURIHandler() async {
    bool foundLink = false;
    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;
    if (deepLink != null) {
      foundLink = true;
      afterSplash(articleId: deepLink.queryParameters["article_id"]);
    }

    FirebaseDynamicLinks.instance.onLink.listen((dynamicLink) async {
      if (dynamicLink !=null ) {
        final Uri? deepLink = dynamicLink.link;
        if (deepLink != null) {
          foundLink = true;
          afterSplash(articleId: deepLink.queryParameters["article_id"]);
        } else
          afterSplash();
      } else
        afterSplash();
    });

    await Future.delayed(Duration(milliseconds: 1500));
    if (!foundLink) {
      afterSplash();
    }
  }

  void _incomingLinkHandler() {
    if (!kIsWeb) {
      _streamSubscription = uriLinkStream.listen((Uri? uri) {
        if (!mounted) {
          return;
        }
        debugPrint('Received URI: $uri');
        setState(() {
          _currentURI = uri;
          _err = null;
        });
      }, onError: (Object err) {
        if (!mounted) {
          return;
        }
        debugPrint('Error occurred: $err');
        setState(() {
          _currentURI = null;
          if (err is FormatException) {
            _err = err;
          } else {
            _err = null;
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Stack(children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(Config().splashbg),
            ),
          ),
        ),
/*
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              gradient: LinearGradient(
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.black,
                  ],
                  stops: [
                    0.0,
                    1.0
                  ])),
        ),
*/
/*
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
                padding: EdgeInsets.only(bottom: 50),
                child: Center(child: RichText(
                  text: TextSpan(
                    text: 'Meir',   //first part
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 41,
                        fontWeight: FontWeight.w900,
                        color: Color(0xffADD8E6)),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'Eliyahu',  //second part
                          style:
                          TextStyle(fontFamily: 'Poppins', color: Color(0xff00008B))),
                    ],
                  ),
                ))),
            Padding(
                padding: EdgeInsets.only(bottom: 50),
                child: Center(child: Column(
                  children: [
                    Text(" לעילוי נשמות\nר' שלמה חיים בן עוזר\nמרת פרחה בת אברהם\nמרת מינדל בת אברהם ", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.white),),
                  ],
                )))

          ],
        )
*/
      ]),
/*
      body: Center(
          child: Image(
        image: AssetImage(Config().splashIcon),
        height: 120,
        width: 120,
        fit: BoxFit.contain,
      )),
*/
    );
  }
}
