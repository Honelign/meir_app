import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:news_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JustAudioPlayerHandler extends BaseAudioHandler with SeekHandler {

  final _player = AudioPlayer();

  /// Initialise our audio handler.
  JustAudioPlayerHandler() {
    // So that our clients (the Flutter UI and the system notification) know
    // what state to display, here we set up our audio handler to broadcast all
    // playback state changes as they happen via playbackState...
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    // ... and also the current media item via mediaItem.
    //mediaItem.add(_item);

    // Load the player.
    //_player.setAudioSource(AudioSource.uri(Uri.parse(_item.id)));
  }

  // In this simple example, we handle only 4 actions: play, pause, seek and
  // stop. Any button press from the Flutter UI, notification, lock screen or
  // headset will be routed through to these 4 methods so that you can handle
  // your audio playback logic in one place.

  @override
  Future<void> play() async {
    /*SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('CurrentPlayingState', "Playing");*/
    return _player.play();
  }

  @override
  Future<void> pause() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('CurrentPlayingItemId', this.mediaItem.value!.id);
    await prefs.setString('CurrentPlayingItemTitle', this.mediaItem.value!.title);
    await prefs.setString('CurrentPlayingItemDuration', this.mediaItem.value!.duration!.inSeconds.toString());
    String? url = mediaItem.value!.title;
    await prefs.setString(url, _player.position.inSeconds.toString());
    return _player.pause();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? url = mediaItem.value!.title;
    await prefs.remove('CurrentPlayingItemId');
    await prefs.remove('CurrentPlayingItemTitle');
    await prefs.remove('CurrentPlayingItemDuration');
    await prefs.remove("CurrentPlayingPosition");

    await prefs.setString(url, _player.position.inSeconds.toString());
    this.mediaItem.add(null);
    /*SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('CurrentPlayingState', "Stopped");*/
    _player.stop();
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? durationSeconds = await prefs.getString(mediaItem.title);
    if (durationSeconds != null && durationSeconds.isNotEmpty && durationSeconds != 'null') {
      Duration position = Duration(seconds: int.parse(durationSeconds));
      this.mediaItem.add(mediaItem);
      _player.setAudioSource(
          AudioSource.uri(Uri.parse(mediaItem.id)), initialPosition: position);
    } else {
      this.mediaItem.add(mediaItem);
      _player.setAudioSource(
          AudioSource.uri(Uri.parse(mediaItem.id)));
    }

    _player.play();
  }


  @override
  Future<void> setSpeed(double speed) async {
    _player.setSpeed(speed);
  }


/*
  @override
  Future<void> onNotificationDeleted() async {
    stop();
  }
*/

  /// Transform a just_audio event into an audio_service state.
  ///
  /// This method is used from the constructor. Every event received from the
  /// just_audio player will be transformed into an audio_service state so that
  /// it can be broadcast to audio_service clients.
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else
          MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}