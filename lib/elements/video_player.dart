import 'package:blog_app/models/blog_category.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as convert;
import 'package:youtube_plyr_iframe/youtube_plyr_iframe.dart';

class CustomVideoPlayer extends StatefulWidget {
  final Blog blog;
  CustomVideoPlayer({Key key, this.blog}) : super(key: key);

  @override
  CustomVideoPlayerState createState() => CustomVideoPlayerState();
}

class CustomVideoPlayerState extends State<CustomVideoPlayer> {
  YoutubePlayerController controller;
  @override
  void initState() {
    super.initState();
    final videoId = convert.YoutubePlayer.convertUrlToId(
      widget.blog.videoUrl,
    );
    controller = YoutubePlayerController(
      initialVideoId: videoId,
      params: YoutubePlayerParams(
        mute: false,
        autoPlay: true,
        enableJavaScript: false,
        enableCaption: false,
        desktopMode: false,
        showControls: true,
      ),
    );
    controller.play();
  }

  vidoPlayPauseTogal(bool isPause) {
    if (isPause) {
      setState(() {
        print("object stop");
        controller.stop();
      });
    } else {
      controller.stop();
      print("object play");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      width: MediaQuery.of(context).size.width,
      child: YoutubePlayerIFrame(
        controller: controller,
        aspectRatio: 16 / 9,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller.pause();
  }

  @override
  void deactivate() {
    super.deactivate();
    controller.pause();
  }

  @override
  void dispose() {
    super.dispose();
    if (controller != null) controller.close();
  }
}
