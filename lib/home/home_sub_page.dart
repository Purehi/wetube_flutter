import 'package:flutter/material.dart';
import 'package:wetube_flutter/player/youtube_player_page.dart';
import 'package:youtube_data_api/models/video.dart';
import 'package:youtube_data_api/youtube_data_api.dart';

import '../widgets/video_card.dart';
class HomeSubPage extends StatefulWidget {
  const HomeSubPage({super.key, required this.index});
  final int index;

  @override
  State<HomeSubPage> createState() => _HomeSubPageState();
}

class _HomeSubPageState extends State<HomeSubPage> with  AutomaticKeepAliveClientMixin{
  final List<Video> _videos = [];
  @override
  void initState() {
    YoutubeDataApi youtubeDataApi = YoutubeDataApi();
    if(widget.index == 0){
      youtubeDataApi.fetchTrendingVideo().then((videos){
        setState(() {
          _videos.addAll(videos);
        });
      });
    }else if(widget.index == 1){
      youtubeDataApi.fetchTrendingMusic().then((videos){
        setState(() {
          _videos.addAll(videos);
        });
      });
    }else if(widget.index == 1){
      youtubeDataApi.fetchTrendingGaming().then((videos){
        setState(() {
          _videos.addAll(videos);
        });
      });
    }else{
      youtubeDataApi.fetchTrendingMovies().then((videos){
        setState(() {
          _videos.addAll(videos);
        });
      });
    }

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView.builder(
        itemBuilder: (context, index) {
          final video = _videos[index];
          return InkWell(
            onTap: (){
              Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                builder: (_) => YoutubePlayerPage(video: video),));
            },
            child: VideoCard(
                video: video,
            )
          );
        },
        itemCount: _videos.length,
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
