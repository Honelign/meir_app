import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart' as justaudio;
import 'package:news_app/config/config.dart';
import 'package:news_app/main.dart';
import 'package:news_app/widgets/play_pause_button.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String url;
  final String title;
  final bool isAsset;

  const AudioPlayerWidget({
    Key? key,
    required this.url,
    required this.title,
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
  late MediaItem item;

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

/*
    _audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
      setState(() {
        _playerState = PlayerState.stopped;
      });
    });
*/

    getDuration(widget.url).then((duration) => {
          item = MediaItem(
            id: widget.url,
            album: 'Album name',
            title: widget.title,
            artist: 'Artist name',
            duration: duration,
          )
        });

    super.initState();
  }

  Future<Duration?> getDuration(String url) async {
    final tempPlayer = justaudio.AudioPlayer();
    var duration = await tempPlayer.setUrl(url);
    return duration;
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
        TextButton(
            onPressed: () {
              audioHandler.playMediaItem(item);
              Navigator.pop(context);
            },
            child: Icon(Icons.play_circle_fill, size: 65))
/*
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
                      color: _isPlaying ? Colors.orangeAccent : Colors.black54,
                      size: 34,
                    ),
                    onPressed: () {
                      if (audioHandler.mediaItem.value != null)
                        audioHandler.play();
                      else
                        audioHandler.playMediaItem(item);
                      //_play();
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
              description: Text(
                  'Anytime you PAUSE or leave a PODCAST, when you return, we will remember where you left off!'),
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
                        color: _isPaused ? Colors.orangeAccent : Colors.black54,
                        size: 34,
                      ),
                      onPressed: () {
                        audioHandler.pause();
                        //_pause();
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
                      audioHandler.stop();
                      //_stop();
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
                  child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Center(
                          child: Text(
                        playbackRate.toString() + 'x',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ))),
                ),
              ),
              title: Text('Playback speed'),
              description: Text(
                  'You can now listen FASTER or SLOWER to all PODCASTS on our app!'),
              backgroundColor: Theme.of(context).primaryColor,
              targetColor: Colors.white,
              textColor: Colors.white,
              child: StreamBuilder<double>(
                stream: audioHandler.playbackState
                    .map((state) => state.speed)
                    .distinct(),
                builder: (context, snapshot) {
                  double speed = snapshot.data ?? 1.0;
                  return ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(22)),
                    child: Container(
                      width: 70,
                      height: 50,
                      color: Color(0x66AAAAAA),
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
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54),
                            ))),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
*/
        /*StreamBuilder<MediaState>(
          stream: mediaStateStream,
          builder: (context, snapshot) {
            final mediaState = snapshot.data;
            return Slider.adaptive(
              activeColor: Colors.orangeAccent,
              onChanged: (double value) {
                setState(() {
                  //_audioPlayer.seek(Duration(seconds: value.toInt()));
                  audioHandler.seek(Duration(seconds: value.toInt()));
                });
              },
              min: 0.0,
              //max: durationN ==null || durationN.inSeconds.isNaN==true || durationN.inSeconds==null? 1.0 : durationN.inSeconds.toDouble() + 1.0,
              max: (mediaState?.mediaItem?.duration ?? Duration.zero).inSeconds.toDouble(),
              //value: positionN== null || positionN.inSeconds.isNaN==true || positionN.inSeconds==null? 0 : positionN.inSeconds.toDouble(),
              value: (mediaState?.position ?? Duration.zero).inSeconds.toDouble(),
            );
          },
        ),*/
/*
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // A seek bar.
            StreamBuilder<MediaState>(
              stream: mediaStateStream,
              builder: (context, snapshot) {
                final mediaState = snapshot.data;
                return SeekBar(
                  duration: mediaState?.mediaItem?.duration ?? Duration.zero,
                  position: mediaState?.position ?? Duration.zero,
                  onChangeEnd: (newPosition) {
                    audioHandler.seek(newPosition);
                  },
                );
              },
            ),
          ],
        ),
*/
        /*Row(
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
        ),*/
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
          _playerState = PlayerState.playing;
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
              style: Theme.of(context).textTheme.caption),
        ),
      ],
    );
  }

  Duration get _remaining => widget.duration - widget.position;
}

class HiddenThumbComponentShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {}
}
