import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {

  late AudioPlayer _audioPlayer;
  late AudioCache _audioCache;

  PlayerState playerState = PlayerState.stopped;

  bool get isPlaying => playerState == PlayerState.playing;
  bool get isPaused => playerState == PlayerState.paused;

  Duration _duration = Duration();
  Duration _position = Duration();
  double playbackRate = 1.0;

  /// Initialise our audio handler.
  AudioPlayerHandler() {

    /*
    * Before Migration
    * */
/*
    _audioPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
    _audioCache = AudioCache(fixedPlayer: _audioPlayer);
*/

    /*
    * After Migration.
    * */
    _audioPlayer = AudioPlayer();
    _audioCache = AudioCache();
  }

  // The most common callbacks:
  Future<void> play() async {}
  Future<void> pause() async {
    _audioPlayer.pause();
  }
  Future<void> stop() async {
    _audioPlayer.stop();
  }
  Future<void> seek(Duration position) async {}
  Future<void> skipToQueueItem(int i) async {}

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    /*
    * Before Migration
    * */
    //_audioPlayer.play(mediaItem.id, isLocal: false);

    /*
    * After Migration
    * */

    _audioPlayer.play(UrlSource(mediaItem.id), mode: PlayerMode.mediaPlayer);
  }


}

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}