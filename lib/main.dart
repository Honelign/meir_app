import 'package:audio_service/audio_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:news_app/services/just_audio_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'package:rxdart/rxdart.dart';

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}
late JustAudioPlayerHandler audioHandler;
Stream<MediaState> get mediaStateStream =>
    Rx.combineLatest2<MediaItem?, Duration, MediaState>(
        audioHandler.mediaItem,
        AudioService.position,
            (mediaItem, position) => MediaState(mediaItem, position));

void main()async {
  audioHandler = await AudioService.init(
    builder: () => JustAudioPlayerHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'ravamiller.torahapp.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: false,
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int nbTimesLaunched = (prefs.getInt('nbTimesLaunched') ?? 0) + 1;
  await prefs.setInt('nbTimesLaunched', nbTimesLaunched);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark
  ));
  //HttpOverrides.global = new MyHttpOverrides();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('es'), Locale('ar'), Locale('iw')],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      startLocale: Locale('en'),
      useOnlyLangCode: true,
      child: FeatureDiscovery(child: MyApp()),
    )
  );

}

// class MyHttpOverrides extends HttpOverrides{
//   @override
//   HttpClient createHttpClient(SecurityContext? context){
//     return super.createHttpClient(context)
//       ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
//   }
// }

