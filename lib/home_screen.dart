// ignore_for_file: unused_element, unnecessary_null_comparison, import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:youtube_ui/services/api_service.dart';
import 'package:youtube_ui/utils/channel_model.dart';
import 'package:youtube_ui/utils/video_model.dart';
import 'package:youtube_ui/utils/video_screen.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Channel? _channel;
  bool _isloading = false;

  @override
  void initState() {
    super.initState();
    _initChannel();
  }

  _initChannel() async {
    Channel channel = await APIService.instance
        .fetchChannel(channelId: 'UCb_g6_uiljgeMDPMO98QEFQ');
    setState(() {
      _channel = channel;
    });
  }

  _builProfileInfo() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      height: 100,
      decoration: const BoxDecoration(color: Colors.black, boxShadow: [
        BoxShadow(color: Colors.white54, offset: Offset(0, 1), blurRadius: 6)
      ]),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.black,
            radius: 35,
            backgroundImage: NetworkImage(_channel!.profilePictureUrl),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _channel!.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${_channel!.subscriberCount} subscribers',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
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

  _buildSlider(Video video) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(5),
      alignment: Alignment.center,
      constraints: const BoxConstraints.expand(
        height: 225,
      ),
      child: Swiper(
        autoplay: true,
        itemBuilder: (context, index) {
          return Image.network(
            video.thumbnailUrl,
            fit: BoxFit.fitHeight,
          );
        },
        itemCount: video.thumbnailUrl.length,
        viewportFraction: 0.7,
        scale: 0.8,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'YouTube Channel',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),
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
                    return _builProfileInfo();
                  }
                  if (index == 1) {
                    Video video = _channel!.videos[index];
                    return _buildSlider(video);
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
