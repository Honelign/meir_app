import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vimeo_player_flutter/vimeo_player_flutter.dart';

class LocalVideoPlayer extends StatefulWidget {
  const LocalVideoPlayer({Key? key, required this.videoUrl}) : super(key: key);

  final String videoUrl;

  @override
  _LocalVideoPlayerState createState() => _LocalVideoPlayerState();
}

class _LocalVideoPlayerState extends State<LocalVideoPlayer> {
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    super.initState();
    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(BetterPlayerDataSourceType.network, widget.videoUrl, videoFormat: BetterPlayerVideoFormat.hls);
    _betterPlayerController = BetterPlayerController(
      
      BetterPlayerConfiguration(
        deviceOrientationsAfterFullScreen: const [DeviceOrientation.portraitUp],
        aspectRatio: 16/9,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableSkips: false, 
          enableOverflowMenu: false
        )
      ),
      betterPlayerDataSource: betterPlayerDataSource,
      
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: 16 / 9,
        child: widget.videoUrl.contains("vimeo.com") ? VimeoPlayer(
          videoId: widget.videoUrl.replaceAll("https://vimeo.com/", "").replaceAll("?share=copy", ""),
        ) : BetterPlayer(
          controller: _betterPlayerController,
        )
/*
        child: BetterPlayer(
          controller: _betterPlayerController,
        )
*/
    );
  }
}