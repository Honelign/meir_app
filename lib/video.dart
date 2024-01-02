import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_playout/multiaudio/HLSManifestLanguage.dart';
import 'package:flutter_playout/multiaudio/MultiAudioSupport.dart';
import 'package:flutter_playout/player_observer.dart';
import 'package:flutter_playout/player_state.dart';
import 'package:flutter_playout/video.dart';
import 'package:news_app/hls/getManifestLanguages.dart';

class VideoPlayout extends StatefulWidget {
  final String url;
  final PlayerState desiredState;
  final bool showPlayerControls;

  VideoPlayout({
    required this.url,
    required this.desiredState,
    required this.showPlayerControls,
  });

  @override
  _VideoPlayoutState createState() => _VideoPlayoutState();
}

class _VideoPlayoutState extends State<VideoPlayout>
    with PlayerObserver, MultiAudioSupport {
  String _url = "https://www.youtube.com/watch?v=nMqR62V0vaI";
  List<HLSManifestLanguage> _hlsLanguages = [];

  @override
  void initState() {
    super.initState();
    _url = widget.url;
    Future.delayed(Duration.zero, _getHLSManifestLanguages);
  }

  Future<void> _getHLSManifestLanguages() async {
    if (!Platform.isIOS && _url.isNotEmpty) {
      _hlsLanguages = await getManifestLanguages(_url);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          /* player */
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Video(
              autoPlay: true,
              showControls: widget.showPlayerControls,
              title: "MTA International",
              subtitle: "Reaching The Corners Of The Earth",
              preferredAudioLanguage: "eng",
              isLiveStream: false,
              position: 0,
              url: _url,
              // "https://user-images.githubusercontent.com/28951144/229373695-22f88f13-d18f-4288-9bf1-c3e078d83722.mp4",
              // widget.url,
              onViewCreated: _onViewCreated,
              desiredState: widget.desiredState,
              preferredTextLanguage: "en",
              loop: false,
            ),
          ),
          /* multi language menu */
          _hlsLanguages.length < 2 && !Platform.isIOS
              ? Container()
              : Container(
                  child: Row(
                    children: _hlsLanguages
                        .map((e) => MaterialButton(
                              child: Text(e.name ?? '',
                                  style:
                                      Theme.of(context).textTheme.labelLarge),
                              onPressed: () {
                                setPreferredAudioLanguage(e.code ?? '');
                              },
                            ))
                        .toList(),
                  ),
                ),
        ],
      ),
    );
  }

  void _onViewCreated(int viewId) {
    listenForVideoPlayerEvents(viewId);
    enableMultiAudioSupport(viewId);
  }

  @override
  void onPlay() {
    // TODO: implement onPlay
    super.onPlay();
  }

  @override
  void onPause() {
    // TODO: implement onPause
    super.onPause();
  }

  @override
  void onComplete() {
    // TODO: implement onComplete
    super.onComplete();
  }
}
