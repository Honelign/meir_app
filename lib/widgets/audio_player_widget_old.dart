import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:news_app/config/config.dart';
import 'package:news_app/main.dart';
import 'package:news_app/widgets/play_pause_button.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String url;
  final bool isAsset;

  const AudioPlayerWidget({
    Key? key,
    required this.url,
    this.isAsset = false,
  }) : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  late AudioCache _audioCache;

  PlayerState _playerState = PlayerState.stopped;

  bool get _isPlaying => _playerState == PlayerState.playing;
  bool get _isPaused => _playerState == PlayerState.paused;

  bool get _isLocal => !widget.url.contains('https');

  bool isPlaying = false;
  Duration _duration = Duration();
  Duration _position = Duration();
  double playbackRate = 1.0;

  @override
  void initState() {
    _audioPlayer = AudioPlayer();
    _audioCache = AudioCache();
    //AudioPlayer.logEnabled = true;

    _audioPlayer.onPositionChanged.listen((Duration duration) {
      setState(() {
        _position = duration;
      });
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        _duration = duration;
      });
    });

    /*_audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
      setState(() {
        _playerState = PlayerState.STOPPED;
      });
    });*/
    super.initState();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(22)),
              child: Container(
                width: 50,
                height: 50,
                color: Color(0x66AAAAAA),
                child: IconButton(
                    icon: Icon(
                          Icons.play_circle_filled,
                      color: _isPlaying ? Colors.orangeAccent: Colors.black54,
                      size: 34,
                    ),
                    onPressed: () {
                      _play();
                      /*if (isPlaying) {
                            _audioPlayer.pause();

                            setState(() {
                              isPlaying = false;
                            });
                          } else {
                            _audioPlayer.resume();
                            setState(() {
                              isPlaying = true;
                            });
                          }*/
                    }),
              ),
            ),
            SizedBox(width: 10.0),
            DescribedFeatureOverlay(
              featureId: 'pause_id',
              tapTarget: Icon(
                Icons.pause_circle_filled,
                color: Colors.black54,
                size: 34,
              ),
              title: Text('Pause / Play'),
              description: Text('Anytime you PAUSE or leave a PODCAST, when you return, we will remember where you left off!'),
              backgroundColor: Theme.of(context).primaryColor,
              targetColor: Colors.white,
              textColor: Colors.white,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(22)),
                child: Container(
                  width: 50,
                  height: 50,
                  color: Color(0x66AAAAAA),
                  child: IconButton(
                      icon: Icon(
                        Icons.pause_circle_filled,
                        color: _isPaused ? Config().appColor : Colors.black54,
                        size: 34,
                      ),
                      onPressed: () {
                        _pause();
                        /*if (isPlaying) {
                            _audioPlayer.pause();

                            setState(() {
                              isPlaying = false;
                            });
                          } else {
                            _audioPlayer.resume();
                            setState(() {
                              isPlaying = true;
                            });
                          }*/
                      }),
                ),
              ),
            ),
            SizedBox(width: 10.0),
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(22)),
              child: Container(
                width: 50,
                height: 50,
                color: Color(0x66AAAAAA),
                child: IconButton(
                    icon: Icon(
                        Icons.stop,
                      color: Colors.black54,
                      size: 34,
                    ),
                    onPressed: () {
                      _stop();
                      /*if (isPlaying) {
                            _audioPlayer.pause();

                            setState(() {
                              isPlaying = false;
                            });
                          } else {
                            _audioPlayer.resume();
                            setState(() {
                              isPlaying = true;
                            });
                          }*/
                    }),
              ),
            ),
            SizedBox(width: 10.0),
            DescribedFeatureOverlay(
              featureId: 'speed_id',
              tapTarget: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(22)),
                child: Container(
                  width: 70,
                  height: 50,
                  color: Color(0x66AAAAAA),
                  child: Padding(padding: EdgeInsets.all(5.0),
                      child: Center(child: Text(playbackRate.toString() + 'x', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),))),
                ),
              ),
              title: Text('Playback speed'),
              description: Text('You can now listen FASTER or SLOWER to all PODCASTS on our app!'),
              backgroundColor: Theme.of(context).primaryColor,
              targetColor: Colors.white,
              textColor: Colors.white,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(22)),
                child: Container(
                  width: 70,
                  height: 50,
                  color: Color(0x66AAAAAA),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (playbackRate == 1.75)
                          playbackRate = 1.0;
                        else
                          playbackRate = playbackRate + 0.25;
                        _audioPlayer.setPlaybackRate(playbackRate);
                      });
                    },
                    child: Padding(padding: EdgeInsets.all(5.0),
                        child: Center(child: Text(playbackRate.toString() + 'x', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),))),
                  ),
                ),
              ),
            ),
          ],
        ),
        Slider.adaptive(
          activeColor: Config().appColor,
          onChanged: (double value) {
            setState(() {
              _audioPlayer.seek(Duration(seconds: value.toInt()));
            });
          },
          min: 0.0,
          max: _duration ==null || _duration.inSeconds.isNaN==true || _duration.inSeconds==null? 1.0 : _duration.inSeconds.toDouble() + 1.0,
          value: _position== null || _position.inSeconds.isNaN==true || _position.inSeconds==null? 0 : _position.inSeconds.toDouble(),
        ),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              _position.toString().split(".")[0],
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(" / "),
            Text(
              _duration.toString().split(".")[0],
              style: TextStyle(fontWeight: FontWeight.w300),
            ),
          ],
        ),
        TextButton(onPressed: () {
          audioHandler.stop();
          var item = MediaItem(
            id: widget.url,
            album: 'Album name',
            title: 'Track title',
            artist: 'Artist name'
          );
          audioHandler.playMediaItem(item);
        }, child: Text("Play BG")),
        TextButton(onPressed: () {
          audioHandler.stop();
        }, child: Text("Stop BG"))
      ],
    );
/*
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PlayPauseButton(
            isPlaying: _isPlaying,
            onPlay: () => _playPause()
        ),
        IconButton(
          onPressed: () => _stop(),
          icon: Icon(
            Icons.stop,
            size: 32,
            color: Colors.red,
          ),
        ),
      ],
    );
*/
  }

  _play() async {
    if (_playerState == PlayerState.paused) {
      final playerResult = await _audioPlayer.resume();
      _audioPlayer.setPlaybackRate(playbackRate);
      //if (playerResult == 1) {
        setState(() {
          _playerState = PlayerState.playing;
        });
      //}
    } else {
      /*if (widget.isAsset) {
        _audioPlayer = await _audioCache.play(widget.url);
        _audioPlayer.setPlaybackRate(playbackRate);
        setState(() {
          _playerState = PlayerState.PLAYING;
        });
      } else {*/
        final playerResult =
        await _audioPlayer.play(UrlSource(widget.url), mode: PlayerMode.mediaPlayer);
        _audioPlayer.setPlaybackRate(playbackRate);
        //if (playerResult == 1) {
          setState(() {
            _playerState = PlayerState.playing;
          });
        //}
      //}
    }
  }

  _pause() async {
    if (_playerState == PlayerState.playing) {
      final playerResult = await _audioPlayer.pause();
      //if (playerResult == 1) {
        setState(() {
          _playerState = PlayerState.paused;
        });
      //}
    }
  }

  _stop() async {
    final playerResult = await _audioPlayer.stop();
    //if (playerResult == 1) {
      setState(() {
        _position = Duration();
        _playerState = PlayerState.stopped;
      });
    //}
  }
}
