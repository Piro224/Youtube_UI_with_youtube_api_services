// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:youtube_ui/services/api_service.dart';
import 'package:youtube_ui/utils/channel_model.dart';
import 'package:youtube_ui/utils/video_model.dart';

class VideoScreen extends StatefulWidget {
  final String id;

  const VideoScreen({required this.id});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  Channel? _channel;
  bool _isloading = false;

  _initChannel() async {
    Channel channel = await APIService.instance
        .fetchChannel(channelId: 'UCb_g6_uiljgeMDPMO98QEFQ');
    setState(() {
      _channel = channel;
    });
  }

  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initChannel();

    _controller = YoutubePlayerController(
      initialVideoId: widget.id,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
      ),
    );
  }

  _buildVideo(Video video) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoScreen(id: video.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 5,
        ),
        padding: const EdgeInsets.all(10),
        height: 140,
        decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.white,
                offset: Offset(0, 1),
                blurRadius: 6,
              ),
            ]),
        child: Row(
          children: [
            Image(
              width: 150,
              image: NetworkImage(
                video.thumbnailUrl,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                video.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _loadMorevideos() async {
    _isloading = true;
    List<Video> moreVideo = await APIService.instance
        .fetchVideosFromPlaylist(playlistId: _channel!.uploadPlaylistId);
    List<Video> allVideos = _channel!.videos..addAll(moreVideo);
    setState(() {
      _channel!.videos = allVideos;
    });
    _isloading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _channel != null
          ? NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollDetails) {
                if (!_isloading &&
                    _channel!.videos.length !=
                        int.parse(_channel!.videoCount) &&
                    scrollDetails.metrics.pixels ==
                        scrollDetails.metrics.maxScrollExtent) {
                  _loadMorevideos();
                }
                return false;
              },
              child: ListView.builder(
                itemCount: 1 + _channel!.videos.length,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return YoutubePlayer(
                      controller: _controller!,
                      showVideoProgressIndicator: true,
                      onReady: () {
                        debugPrint('Player is ready.');
                      },
                    );
                  }
                  Video video = _channel!.videos[index - 1];
                  return _buildVideo(video);
                },
              ),
            )
          : const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
    );
  }
}
